defmodule TrashDuty.Mixfile do
  use Mix.Project

  def project do
    [
      app: :trash_duty,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :dev,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TrashDuty.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:slack, "~> 0.12.0"},
      {:quantum, ">= 2.1.0"},
      {:timex, "~> 3.0"}
    ]
  end
end
