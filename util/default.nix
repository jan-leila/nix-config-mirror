{lib, ...}: {
  mkUnless = condition: yes: (lib.mkIf (!condition) yes);
  mkIfElse = condition: yes: no:
    lib.mkMerge [
      (lib.mkIf condition yes)
      (lib.mkUnless condition no)
    ];
}
