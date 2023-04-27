defmodule Ivf.MixProject do
  use Mix.Project

  def project do
    [
      app: :ivf,
      version: "0.2.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end

  defp description() do
    "Collection of convenience functions to work with *.ivf files as described here: https://wiki.multimedia.cx/index.php/Duck_IVF."
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE*),
      licenses: ["0BSD"],
      links: %{"GitHub" => "https://github.com/jnnks/ivf"}
    ]
  end
end
