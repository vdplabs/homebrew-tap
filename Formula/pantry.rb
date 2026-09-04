class Pantry < Formula
  include Language::Python::Virtualenv

  desc "Local Apple Silicon model host with capability resolve"
  homepage "https://github.com/vdplabs/pantry"
  url "https://github.com/vdplabs/pantry/archive/refs/tags/v0.5.1.tar.gz"
  sha256 "e292a2a623331488797b404d6b32103af226cb2e5aef384c377c4fd0721a6779"
  license "MIT"
  head "https://github.com/vdplabs/pantry.git", branch: "main"

  depends_on "python@3.12"

  def install
    virtualenv_create(libexec, "python3.12")
    python = formula_opt_bin("python@3.12")/"python3.12"

    deps = [
      "fastapi",
      "uvicorn[standard]",
      "pydantic",
      "typer",
      "httpx",
      "huggingface_hub",
      "python-multipart",
      "rumps",
    ]

    # Install core dependencies into virtualenv without Homebrew's --no-binary=:all:
    system python, "-m", "pip", "--python=#{libexec}/bin/python", "install", *deps

    # Install Apple Silicon MLX extras (only available as pre-built wheels on PyPI)
    if Hardware::CPU.arm?
      mlx_deps = if MacOS.version <= :ventura
        ["mlx<=0.29.3", "mlx-lm<=0.30.2"]
      else
        ["mlx", "mlx-lm"]
      end
      begin
        system python, "-m", "pip", "--python=#{libexec}/bin/python", "install", *mlx_deps
      rescue BuildError => e
        opoo "MLX could not be installed automatically: #{e.message}"
      end
    end

    # Install pantry package into the virtualenv
    system python, "-m", "pip", "--python=#{libexec}/bin/python", "install", "--no-deps", buildpath

    # Symlink the pantry command to bin
    bin.install_symlink libexec/"bin/pantry"
  end

  def post_install
    # Re-sign installed native C-extensions and dylibs with native Apple codesign
    # to prevent 'Namespace CODESIGNING, Code 2, Invalid Page' errors on Apple Silicon.
    if Hardware::CPU.arm?
      Dir["#{libexec}/**/*.{so,dylib}"].each do |lib|
        system "codesign", "--force", "--sign", "-", lib
      end
    end
  end

  def caveats
    <<~EOS
      Initialize and run:
        pantry init
        pantry pull vdplabs.qwen25-0.5b.compact.v1
        pantry serve

      `pantry serve` opens the Mac menu bar when rumps is present (included).
      Use `pantry serve --no-menubar` for HTTP only.

      On Intel Macs, install MLX extras yourself if needed:
        #{formula_opt_bin("python@3.12")}/python3.12 -m pip --python=#{libexec}/bin/python install mlx mlx-lm
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pantry version")
  end
end
