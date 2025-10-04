%{
  configs: [
    %{
      name: "default",
      files: %{
        included: [
          "apps/*/lib/",
          "apps/*/test/",
          "config/"
        ],
        excluded: [
          ~r"/_build/",
          ~r"/deps/",
          ~r"/node_modules/"
        ]
      },
      strict: false,
      color: true,
      checks: %{
        enabled: [
          {Credo.Check.Consistency.ExceptionNames, []},
          {Credo.Check.Consistency.LineEndings, []},
          {Credo.Check.Consistency.ParameterPatternMatching, []},
          {Credo.Check.Consistency.SpaceAroundOperators, []},
          {Credo.Check.Consistency.SpaceInParentheses, []},
          {Credo.Check.Consistency.TabsOrSpaces, []},
          {Credo.Check.Design.AliasUsage, [priority: :low, if_nested_deeper_than: 2, if_called_more_often_than: 0]},
          {Credo.Check.Readability.MaxLineLength, [priority: :low, max_length: 120]},
          {Credo.Check.Readability.ModuleDoc, false}
        ]
      }
    }
  ]
}
