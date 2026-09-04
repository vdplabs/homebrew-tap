class Pantry < Formula
  include Language::Python::Virtualenv

  desc "Local Apple Silicon model host with capability resolve"
  homepage "https://github.com/vdplabs/pantry"
  url "https://github.com/vdplabs/pantry/archive/refs/tags/v0.4.1.tar.gz"
  sha256 "1a639ab06f5b4fdc5e13ff1c5c3a9eee6000150e16ebf611adddde5742496a6f"
  license "MIT"
  head "https://github.com/vdplabs/pantry.git", branch: "main"

  depends_on "python@3.12"

  def install
    venv = virtualenv_create(libexec, "python3.12")
    deps = [
      "fastapi",
      "uvicorn[standard]",
      "pydantic",
      "typer",
      "httpx",
      "huggingface_hub",
      "rumps",
    ]
    venv.pip_install deps

    if Hardware::CPU.arm?
      venv.pip_install ["mlx", "mlx-lm"]
    end

    venv.pip_install_and_link buildpath
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
        #{Formula["python@3.12"].opt_bin}/python3.12 -m pip install --prefix=#{libexec} mlx mlx-lm
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/pantry version")
  end
end
