+++
title = "How to setup an email server using nixos on oracle cloud"
date = 2026-04-13
+++

After I stumbled upon [this lovely guide](https://mtlynch.io/notes/nix-oracle-cloud/) I somehow had a 4 core 24GB Ram server for which I had to find a use case. After I bought the domain of this website I decided to use it for hosting an email server. Since hosting an email server on oracle cloud is not as straight forward as I thought, I decided to write this post.

# Setting up the mailserver

Since setting postfix, dovecot etc. through the official nixos modules is rather cumbersome, I decided to go with a nice flake I found which does most of the heavy lifting: [Simple Nixos Mailserver](https://gitlab.com/simple-nixos-mailserver/nixos-mailserver). So first I added that flake as an input to my servers flake.nix:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    snm = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ...
  };

  nixosConfigurations = {
    cloudnix = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./configuration.nix
        snm.nixosModules.default
        ...
      ];
    };
  };
}
```

After the module is imported we can of course configure the module, I directly enabled convenience features like fulltextsearch and Sieve since I consider them essential for any email provider:

```nix
let
  domain = "plamper.org";
in
{
  security.acme.certs."${config.mailserver.fqdn}" = {
    domain = config.mailserver.fqdn;
  };

  mailserver = {
    enable = true;
    stateVersion = 3;

    fqdn = "mail.${domain}";
    domains = [ domain ];

    certificateScheme = "acme";

    enableImap = true;
    enableSubmission = true;

    # OCI does this
    dkimSigning = false;

    fullTextSearch = {
      enable = true;
      # index new email as they arrive
      autoIndex = true;
      enforced = "body";
    };
    enableManageSieve = true;
  };

  # Remember to open 25, 465, 993, 4190 in oracles webui
  # Nixos firewall is automatically setup through SNM
}
```

But now comes the caveat. Oracle cloud blocks outbound traffic on port 25 by default. You can technically create a support request to remove this restriction but I decided against going down that route, since they offer a generous amount of free emails on their email relay server, 3000 every month, which I am unlikely to exceed. Just keep in mind that every sender needs to be manually approved through their management console. To use their server we can add the following additional configuration:

```nix
{
  # OCI email delivery
  services.postfix.settings.main = {
    relayhost = [ "[smtp.email.eu-frankfurt-1.oci.oraclecloud.com]:587" ];
    smtp_sasl_auth_enable = "yes";
    smtp_sasl_security_options = "noanonymous";
    # Password file content:
    # [smtp.email.eu-frankfurt-1.oci.oraclecloud.com]:587 SMTP_USERNAME:SMTP_PASSWORD
    smtp_sasl_password_maps = "texthash:<path to file with password>";
    smtp_tls_security_level = lib.mkForce "encrypt";
    smtp_tls_CAfile = "/etc/ssl/certs/ca-certificates.crt";
  };
}
```

The login data can be acquired through oracles ui in the top right under User Settings/Saved Passwords/SMTP credentials. After the login data is set up up go to Developer Services/Email Delivery and create a new domain.

## User management through lldap

Since I don't like SNMs default declarative way of handling accounts and I want to use the same logins for different services like nextcloud as well I decided on going with lldap. Setting up lldap and authelia will be topic of a future post tho. My final setup looked like this, I am using a non-standard attribute for the addresses, since I plan to use the standard email attribute for account reset mails:

```nix
{
  mailserver.ldap = {
    enable = true;

    # Internal VPN host with lldap
    uris = [ "ldap://10.20.0.2:3890" ];
    searchBase = "ou=people,dc=plamper,dc=org";

    bind = {
      dn = "uid=admin,ou=people,dc=plamper,dc=org";
      passwordFile = "/pathToPasswordFile";
    };

    dovecot = {
      passFilter = "(&(objectClass=person)(mailboxAddress=%{user}))";
      passAttrs = "userPassword=password";
      userFilter = "(&(objectClass=person)(mailboxAddress=%{user}))";
      userAttrs = null;
    };

    postfix = {
      filter = "(&(objectClass=person)(mailboxAddress=%s))";
      mailAttribute = "mailboxAddress";
      uidAttribute = "mailboxAddress";
    };
  };
}
```

## Necessary DNS records

Now we need to add all the dns records, so the server is actually discoverable on the internet. Additional records like dkmin, spf and so on are used to validate the ownership of the domain to other servers. The following records need to be added:

{% table() %}
| Record Type | Name | Value / Points To | Priority |
| :--- | :--- | :--- | :--- |
| **A** | mail | [Your Server IP] | — |
| **MX** | @ | mail.domain.org | 10 |
| **CNAME** | bounce.fra1 | fra1.rp.oracleemaildelivery.com | - |
| **CNAME** | dkim.\_domainkey | Whatever oracle cloud tells you in their email delivery web portal | - |
| **TXT** | @ | "v=spf1 include:eu.rp.oracleemaildelivery.com ~all" | - |
| **TXT** | \_dmarc | "v=DMARC1; p=none; rua=mailto:[your email]" | - |
{% end %}

Do keep in mind that if your server is not located in Frankfurt you need to change the values accordingly. The dmarc record is not technically necessary, but you'll get nice information sent from participating email servers that can help to debug if spf and dkim are set up correctly. Oracle will take a while to see the records propagate so be patient.

You should now be able to login and send a test email.

## Getting Autoconfiguration working in most email clients

Some email clients, like evolution, already support autoconfiguration via dns records: 

{% table() %}
| Record Type | Name | Value / Points To | Priority |
| :--- | :--- | :--- | :--- |
| **SRV** | _imaps._tcp | 10 1 993 mail.domain.org | 10 |
| **SRV** | _submissions._tcp | 10 1 465 mail.domain.org | 10 |
{% end %}

Most other clients however use a webserver that serves a simple xml file which has the server information inside. Since this is quite tedious to set up you can use [my nixos module](https://github.com/Plamper/nixos-email-autoconfig) which sets up nginx to serve the proper files. Be sure to also create the dns records autoconfig and autodiscover for your domain and point them to the nginx host.

## A few more things that are nice to have

To block multiple failed login attempts I used fail2ban with it's preconfigured dovecot jail:

```nix
{
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    bantime-increment = {
      enable = true;
      factor = "4";
      maxtime = "168h"; # cap at 1 week
    };

    jails = {
      dovecot.settings = {
        enabled = true; 
        maxretry = 5;
      };
    };
  };
}

```

### Backups

SNM also ships with a convenient backup solution:

```nix
{
  mailserver.borgbackup = {
    enable = true;
    repoLocation = "ssh://borg@10.20.0.2/~/mail";
    # Make sure borg can access the host via ssh
    cmdPreexec = ''
      export BORG_RSH="ssh -i /var/vmail/.ssh/id_ed25519"
    '';
  };
}
```

### Masterpassword for nextcloud

Since my nextcloud uses oidc for login, nextcloud doesn't know the users password and therefore autoprovisioning won't work without a master password.

```nix
{
  services.dovecot2.extraConfig = ''
    auth_master_user_separator = *
    passdb {
      driver = passwd-file
      args = /pathToPasswordFile
      master = yes
      pass = yes
    }
  '';
}

```

And then if you did everything right you can provision your domain in nextcloud like so:

{{ image(path="images/nextcloud_settings.png", width=400) }}

# Conclusion

If you have done everything correctly you should have your own mailserver that doesn't end up in the spam folder. I especially enjoy finally being able to use sieve for automatically sorting my mail. You can find the final cleaned up configuration [here](https://github.com/Plamper/nix-nas/blob/main/hosts/cloudnix/mailserver.nix).
