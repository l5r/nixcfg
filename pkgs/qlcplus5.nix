{ qlcplus, fetchFromGitHub }: qlcplus.overrideAttrs (old: rec {
	version = "5.0.0";
	src = fetchFromGitHub {
    	owner = "mcallegari";
    	repo = "qlcplus";
    	rev = "QLC+_${version}";
    	sha256 = "sha256-AKmPxHOlMtea3q0NDULp3XfJ0JnYeF/iFUJw0dDOiio=";
  	};
})
