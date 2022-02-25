{
  napariPkg =
    { mkDerivationWith
    , buildPythonPackage
    , fetchFromGitHub
    , setuptools_scm
    , superqt
    , typing-extensions
    , tifffile
    , napari-plugin-engine
    , pint
    , pyyaml
    , numpydoc
    , dask
    , magicgui
    , docstring-parser
    , appdirs
    , imageio
    , pyopengl
    , cachey
    , napari-svg
    , psutil
    , napari-console
    , wrapt
    , pydantic
    , tqdm
    , jsonschema
    , wrapQtAppsHook
    }: mkDerivationWith buildPythonPackage rec {
      pname = "napari";
      version = "0.4.12";
      src = fetchFromGitHub {
        owner = "napari";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-0QSI0mgDjF70/X58fE7uWwlBUCGY5gsvbCm4oJkp2Yk=";
      };
      nativeBuildInputs = [ setuptools_scm wrapQtAppsHook ];
      propagatedBuildInputs = [
        superqt
        typing-extensions
        tifffile
        napari-plugin-engine
        pint
        pyyaml
        numpydoc
        dask
        magicgui
        docstring-parser
        appdirs
        imageio
        pyopengl
        cachey
        napari-svg
        psutil
        napari-console
        wrapt
        pydantic
        tqdm
        jsonschema
      ];
      SETUPTOOLS_SCM_PRETEND_VERSION = version;
      dontUseSetuptoolsCheck = true;
      postFixup = ''
        wrapQtApp $out/bin/napari
      '';
    };
  superqtPkg =
    { buildPythonPackage
    , fetchFromGitHub
    , setuptools_scm
    , pyqt5
    , pytest
    }: buildPythonPackage rec {
      pname = "superqt";
      version = "0.2.4";
      src = fetchFromGitHub {
        owner = "napari";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-v3Sd1Jnynn1dm2wExVuz+6z90W1Gj5xmX/RTUOBWyCE=";
      };
      nativeBuildInputs = [ setuptools_scm ];
      propagatedBuildInputs = [ pyqt5 pytest ];
      SETUPTOOLS_SCM_PRETEND_VERSION = version;
    };
  napariPluginPkg =
    { buildPythonPackage
    , fetchFromGitHub
    , setuptools_scm
    , pytest
    }: buildPythonPackage rec {
      pname = "napari-plugin-engine";
      version = "0.2.0";
      src = fetchFromGitHub {
        owner = "napari";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-cKpCAEYYRq3UPje7REjzhEe1J9mmrtXs8TBnxWukcNE=";
      };
      nativeBuildInputs = [ setuptools_scm ];
      propagatedBuildInputs = [ pytest ];
      SETUPTOOLS_SCM_PRETEND_VERSION = version;
    };
  magicguiPkg =
    { buildPythonPackage
    , fetchFromGitHub
    , setuptools_scm
    , pytest
    , typing-extensions
    , qtpy
    , psygnal
    , docstring-parser
    }: buildPythonPackage rec {
      pname = "magicgui";
      version = "0.3.0";
      src = fetchFromGitHub {
        owner = "napari";
        repo = "magicgui";
        rev = "v${version}";
        sha256 = "sha256-DvL1szk2RoCrpisjp0BVNL6qFZtYc2oYDenX59Cxbug=";
      };
      nativeBuildInputs = [ setuptools_scm ];
      propagatedBuildInputs = [ pytest typing-extensions qtpy psygnal docstring-parser ];
      doCheck = false;
      SETUPTOOLS_SCM_PRETEND_VERSION = version;
    };
  docstringParserPkg =
    { buildPythonPackage
    , fetchFromGitHub
    , setuptools
    , setuptools_scm
    , wheel
    , pytest
    }: buildPythonPackage rec {
      pname = "docstring-parser";
      version = "0.12";
      src = fetchFromGitHub {
        owner = "rr-";
        repo = "docstring_parser";
        rev = "${version}";
        sha256 = "sha256-hQuPJQrGvDs4dJrMLSR4sSnqy45xrF2ufinBG+azuCg=";
      };
      nativeBuildInputs = [ setuptools_scm ];
      propagatedBuildInputs = [ pytest setuptools wheel ];
      SETUPTOOLS_SCM_PRETEND_VERSION = version;
    };
  psygnalPkg =
    { buildPythonPackage
    , fetchFromGitHub
    , setuptools
    , setuptools_scm
    , wheel
    , pytest
    , typing-extensions
    }: buildPythonPackage rec {
      pname = "psygnal";
      version = "0.1.4";
      src = fetchFromGitHub {
        owner = "tlambert03";
        repo = "psygnal";
        rev = "v${version}";
        sha256 = "sha256-c1u3xbGy3Y+7HuMvbo1covXgbZvEkwRczKtSjtHbDLg=";
      };
      nativeBuildInputs = [ setuptools_scm ];
      propagatedBuildInputs = [ setuptools wheel pytest typing-extensions ];
      SETUPTOOLS_SCM_PRETEND_VERSION = version;
    };
  cacheyPkg =
    { buildPythonPackage
    , fetchFromGitHub
    , setuptools
    , setuptools_scm
    , wheel
    , pytest
    , typing-extensions
    , heapdict
    }: buildPythonPackage rec {
      pname = "cachey";
      version = "0.2.1";
      src = fetchFromGitHub {
        owner = "dask";
        repo = pname;
        rev = "${version}";
        sha256 = "sha256-5USmuufrrWtmgibpfkjo9NtgN30hdl8plJfythmxM4s=";
      };
      nativeBuildInputs = [ setuptools_scm ];
      propagatedBuildInputs = [ setuptools wheel pytest typing-extensions heapdict ];
      SETUPTOOLS_SCM_PRETEND_VERSION = version;
      doCheck = false;
    };
  napariSvgPkg =
    { buildPythonPackage
    , fetchFromGitHub
    , setuptools_scm
    , pytest
    , vispy
    , napari-plugin-engine
    , imageio
    }: buildPythonPackage rec {
      pname = "napari-svg";
      version = "0.1.5";
      src = fetchFromGitHub {
        owner = "napari";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-20NLi6JTugP+hxqF2AnhSkuvhkGGbeG+tT3M2SZbtRc=";
      };
      nativeBuildInputs = [ setuptools_scm ];
      propagatedBuildInputs = [ pytest vispy napari-plugin-engine imageio ];
      SETUPTOOLS_SCM_PRETEND_VERSION = version;
      doCheck = false;
    };
  napariConsolePkg =
    { buildPythonPackage
    , fetchFromGitHub
    , setuptools_scm
    , pytest
    , ipython
    , ipykernel
    , qtconsole
    , napari-plugin-engine
    , imageio
    }: buildPythonPackage rec {
      pname = "napari-console";
      version = "0.0.4";
      src = fetchFromGitHub {
        owner = "napari";
        repo = pname;
        rev = "v${version}";
        sha256 = "sha256-aVdYOzkZ+dqB680oDjNCg6quXU+QgUZI09E/MSTagyA=";
      };
      nativeBuildInputs = [ setuptools_scm ];
      propagatedBuildInputs = [ pytest ipython ipykernel napari-plugin-engine imageio qtconsole ];
      SETUPTOOLS_SCM_PRETEND_VERSION = version;
      doCheck = false;
    };
}
