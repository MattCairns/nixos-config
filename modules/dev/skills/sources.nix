{pkgs}: rec {
  mattPocock = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "2ab958093e83e0ec752e6c1c5932da465bf23e0c";
    hash = "sha256-dQtG6usJWlg/FqTajrjcs8GSdymH92WsgLiUaCfvKPA=";
  };
  typesafeAi = pkgs.fetchFromGitHub {
    owner = "typesafe-ai";
    repo = "skills";
    rev = "65a39f393687675ce170e6094757de20370365b9";
    hash = "sha256-Lh2Y90TFv+njKqo/g5WXEHw0Rk1jQSH5POqKtrvy5kM=";
  };
  ponytail = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    rev = "09c434ab73ca43761c5d8b0c5d341926c2fba710";
    hash = "sha256-sVnxA4rfxa2SlS2g+2+q3odRq0VJz1z7PEVHW2QRPQI=";
  };
  asdSte100 = pkgs.fetchFromGitHub {
    owner = "danyuchn";
    repo = "asd-ste100-skill";
    rev = "d48bfca52a2424b7f17c0de1d718e0c3b9d8f223";
    hash = "sha256-h3rF861xsnhPjI8NTcav6hoTkaU7mFk96eH92hglVqE=";
  };
  # Skill name -> dir, shared by Claude Code and opencode.
  sharedSkills =
    {
      asd-ste100 = "${asdSte100}";
      domain-modeling = "${mattPocock}/skills/engineering/domain-modeling";
      grill-with-docs = "${mattPocock}/skills/engineering/grill-with-docs";
      grilling = "${mattPocock}/skills/productivity/grilling";
      typesafe-ai = "${typesafeAi}/skills/typesafe-ai";
    }
    // pkgs.lib.genAttrs [
      "ponytail"
      "ponytail-audit"
      "ponytail-debt"
      "ponytail-gain"
      "ponytail-help"
      "ponytail-review"
    ] (name: "${ponytail}/skills/${name}");
}
