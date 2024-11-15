# These are the users and systems that will be able to decrypt 
# the .age files later with their corresponding private keys
#
# In other words, users or systems with these corresponding 
# private keys can access the decrypted secrets
let
  # These are the receipient (public) keys that are allowed to decrypt secrets
  darwin.ssh-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINExl/4Qo00yBDbmpb5MhWiQbCJvb31/TYSnyFFIupdp";
  darwin.ssh-user.github = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHesT47TKuKLJjqf1XtJtCmYroSdkToQzWvhDgelIe8A";
  hosts = [ darwin.ssh-host darwin.ssh-user.github ];
in
{
  # Sets both keypairs to be able to decrypt the primary.age file
  "primary.age".publicKeys = hosts;
}
