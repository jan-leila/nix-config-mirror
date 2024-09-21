_: {
  # mkUnless = condition: then: (mkIf (!condition) then);
  # mkIfElse = condition: then: else: lib.mkMerge [
  #   (mkIf condition then)
  #   (mkUnless condition else)
  # ];
}
