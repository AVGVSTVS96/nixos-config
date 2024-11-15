let
  # These are the receipient (public) keys that are allowed to decrypt secrets
  darwin.ssh-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINExl/4Qo00yBDbmpb5MhWiQbCJvb31/TYSnyFFIupdp";
  darwin.ssh-user.github = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHesT47TKuKLJjqf1XtJtCmYroSdkToQzWvhDgelIe8A";
  hosts = [ darwin.ssh-host darwin.ssh-user.github ];
in
{
  "primary.age".publicKeys = hosts;
}
