# This file configures the rules for decrypting secrets
#
# NOTE:
#  To rekey, we must pass an identity key location to agenix
#  `agenix -r -i ~/.secrets/master.age.key`
#
let
  # These are the receipient (public) keys that are allowed to decrypt secrets
  darwin.ssh-host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINExl/4Qo00yBDbmpb5MhWiQbCJvb31/TYSnyFFIupdp";
  master.age = "age1zyeg7s2gwuvzxnd5qxtpx4kmyurm7fn550zjcfug8l3jlsg73qwq7va9pf";

  masterKeys = [
    darwin.ssh-host
    master.age
  ];
in
{
  # Encrypted secrets - decryptable by `masterKeys` defined above
  "primary.age".publicKeys = masterKeys;
  "graphite.age".publicKeys = masterKeys;
  "anthropic.age".publicKeys = masterKeys;
  "openai.age".publicKeys = masterKeys;
}
