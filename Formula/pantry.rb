class Pantry < Formula
  desc "Local Apple Silicon model host with capability resolve"
  homepage "https://github.com/vdplabs/pantry"
  url "https://github.com/vdplabs/pantry/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "1acdd06b59cad4742ca15a983ea24968e6e2fc56b3fb550ceb7febefecc04a9f"
  license "MIT"
  head "https://github.com/vdplabs/pantry.git", branch: "main"

  depends_on "python@3.12"

  def install
    python = Formula["python@3.12"].opt_bin/"python3.12"
    ENV["PIP_DISABLE_PIP_VERSION_CHECK"] = "1"
    py_ver = Language::Python.major_minor_version python

    # Core API deps + menu bar (rumps). MLX is Apple Silicon–heavy; install on arm.
    deps = [
      "fastapi",
      "uvicorn[standard]",
      "pydantic",
      "typer",
      "httpx",
      "huggingface_hub",
      "rumps",
    ]
    system python, "-m", "pip", "install", "--prefix=#{libexec}", *deps

    if Hardware::CPU.arm?
      system python, "-m", "pip", "install", "--prefix=#{libexec}", "mlx", "mlx-lm"
    end

    system python, "-m", "pip", "install", "--prefix=#{libexec}", "."
    bin.install Dir[libexec/"bin/pantry"]
    bin.env_script_all_files(libexec/"bin", {
      PATH:       "#{libexec}/bin:$PATH",
      PYTHONPATH: "#{libexec}/lib/python#{py_ver}/site-packages",
    })
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
