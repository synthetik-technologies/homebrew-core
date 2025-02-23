class PythonTkAT310 < Formula
  desc "Python interface to Tcl/Tk"
  homepage "https://www.python.org/"
  # Keep in sync with python@3.10.
  url "https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz"
  sha256 "c4e0cbad57c90690cb813fb4663ef670b4d0f587d8171e2c42bd4c9245bd2758"
  license "Python-2.0"

  livecheck do
    formula "python@3.10"
  end

  bottle do
    sha256 cellar: :any, arm64_big_sur: "1ee8f1de8afa700ac6e58788ac9bd0441cbc06fff7a7369df8a7381dbedf8c20"
    sha256 cellar: :any, big_sur:       "4cc3cd0c18a7dae959fed8609b8acdce3b1e550336cef5e1be9f816b60e6e352"
    sha256 cellar: :any, catalina:      "85d0c86f5600f8d5254a34fbc75fe0f8425cdaa51b501cbd2fb9645c4ad28ccb"
    sha256 cellar: :any, mojave:        "47aff48291f42c9116239982196d36264afb9b6afbebca2e3f0e8f706960d569"
    sha256               x86_64_linux:  "33e5057494f2cbbeba821221aa97de4c3729c825cf2f47e583081d5bff55267b"
  end

  depends_on "python@3.10"
  depends_on "tcl-tk"

  def install
    cd "Modules" do
      tcltk_version = Formula["tcl-tk"].any_installed_version.major_minor
      (Pathname.pwd/"setup.py").write <<~EOS
        from setuptools import setup, Extension

        setup(name="tkinter",
              description="#{desc}",
              version="#{version}",
              ext_modules = [
                Extension("_tkinter", ["_tkinter.c", "tkappinit.c"],
                          define_macros=[("WITH_APPINIT", 1)],
                          include_dirs=["#{Formula["tcl-tk"].opt_include}"],
                          libraries=["tcl#{tcltk_version}", "tk#{tcltk_version}"],
                          library_dirs=["#{Formula["tcl-tk"].opt_lib}"])
              ]
        )
      EOS
      system Formula["python@3.10"].bin/"python3", *Language::Python.setup_install_args(libexec),
                                                  "--install-lib=#{libexec}"
      rm_r Dir[libexec/"*.egg-info"]
    end
  end

  test do
    system Formula["python@3.10"].bin/"python3", "-c", "import tkinter"

    on_linux do
      # tk does not work in headless mode
      return if ENV["HOMEBREW_GITHUB_ACTIONS"]
    end

    system Formula["python@3.10"].bin/"python3", "-c", "import tkinter; root = tkinter.Tk()"
  end
end
