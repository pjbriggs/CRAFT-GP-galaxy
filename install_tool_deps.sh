#!/bin/bash -e
#
# Install the tool dependencies for CRAFT-GP for testing from command line
#
function install_ruby_1_9() {
    echo Installing Ruby 1.9
    INSTALL_DIR=$1/ruby/1.9
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://depot.galaxyproject.org/software/ruby/ruby_1.9_src_all.tar.gz
    tar xzf ruby_1.9_src_all.tar.gz
    cd ruby-1.9.3-p484
    ./configure --prefix=$INSTALL_DIR --disable-install-doc >/dev/null 2>&1
    make install >/dev/null 2>&1
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup ruby/1.9
echo Setting up ruby 1.9
export PATH=$INSTALL_DIR/bin:\$PATH
export RUBYLIB=$INSTALL_DIR/lib/
export RUBY_HOME=$INSTALL_DIR
export GALAXY_RUBY_HOME=$INSTALL_DIR
#
EOF
}
function install_ruby_2_2_3() {
    echo Installing Ruby 2.2.3
    INSTALL_DIR=$1/ruby/2.2.3
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz
    tar xzf ruby-2.2.3.tar.gz
    cd ruby-2.2.3
    ./configure --prefix=$INSTALL_DIR --disable-install-doc --without-gmp >$INSTALL_DIR/INSTALLATION.log 2>&1
    make install >>$INSTALL_DIR/INSTALLATION.log 2>&1
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup ruby/2.2.3
echo Setting up ruby 2.2.3
export PATH=$INSTALL_DIR/bin:\$PATH
export RUBYLIB=$INSTALL_DIR/lib/
export RUBY_HOME=$INSTALL_DIR
export GALAXY_RUBY_HOME=$INSTALL_DIR
#
EOF
}
function install_python_2_7_10() {
    echo Installing Python 2.7.10
    INSTALL_DIR=$1/python/2.7.10
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://depot.galaxyproject.org/software/python/python_2.7_src_all.tar.gz
    tar xzf python_2.7_src_all.tar.gz
    cd Python-2.7.10
    ./configure --prefix=$INSTALL_DIR --enable-shared --enable-unicode=ucs4 >/dev/null 2>&1
    make install >/dev/null 2>&1
    cd ..
    wget -q https://bitbucket.org/pypa/setuptools/get/18.2.tar.bz2
    tar xjf 18.2.tar.bz2
    cd pypa-setuptools-1a981f2e5031/
    /bin/bash >/dev/null 2>&1 <<EOF
export PATH=$PATH:$INSTALL_DIR/bin && \
export PYTHONHOME=$INSTALL_DIR && \
export PYTHONPATH=$PYTHONPATH:$INSTALL_DIR && \
export PYTHONPATH=$PYTHONPATH:$INSTALL_DIR/lib/python2.7/site-packages/ && \
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$INSTALL_DIR/lib/pkgconfig && \
export LD_LIBRARY_PATH=$INSTALL_DIR/lib/:$LD_LIBRARY_PATH && \
$INSTALL_DIR/bin/python setup.py install --prefix=$INSTALL_DIR
EOF
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup python/2.7.10
echo Setting up python 2.7.10
export PATH=$INSTALL_DIR/bin:\$PATH
export PYTHONPATH=$INSTALL_DIR:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib/python2.7:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib/python2.7/site-packages:\$PYTHONPATH
export PYTHONHOME=$INSTALL_DIR
export PKG_CONFIG_PATH=$INSTALL_DIR/lib/pkgconfig:\$PKG_CONFIG_PATH
export PYTHON_ROOT_DIR=$INSTALL_DIR:\$PYTHON_ROOT_DIR
export LD_LIBRARY_PATH=$INSTALL_DIR:\$LD_LIBRARY_PATH
export C_INCLUDE_PATH=$INSTALL_DIR:\$C_INCLUDE_PATH
export CPLUS_INCLUDE_PATH=$INSTALL_DIR:\$CPLUS_INCLUDE_PATH
#
EOF
}
function install_python_package() {
    echo Installing $2 $3 from $4 under $1
    local install_dir=$1
    local install_dirs="$install_dir $install_dir/bin $install_dir/lib/python2.7/site-packages"
    for d in $install_dirs ; do
	if [ ! -d $d ] ; then
	    mkdir -p $d
	fi
    done
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q $4
    if [ ! -f "$(basename $4)" ] ; then
	echo "No archive $(basename $4)"
	exit 1
    fi
    tar xzf $(basename $4)
    if [ ! -d "$5" ] ; then
	echo "No directory $5"
	exit 1
    fi
    cd $5
    /bin/bash <<EOF
export PYTHONPATH=$install_dir:$PYTHONPATH && \
export PYTHONPATH=$install_dir/lib/python2.7/site-packages:$PYTHONPATH && \
python setup.py install --prefix=$install_dir --install-scripts=$install_dir/bin --install-lib=$install_dir/lib/python2.7/site-packages >>$INSTALL_DIR/INSTALLATION.log 2>&1
EOF
    popd
    rm -rf $wd/*
    rmdir $wd
}
function install_pandas_0_16() {
    echo Installing Pandas 0.16
    INSTALL_DIR=$1/pandas/0.16
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR    # Atlas 3.10 (precompiled)
    # NB this stolen from galaxyproject/iuc-tools
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://depot.galaxyproject.org/software/atlas/atlas_3.10.2_linux_x64.tar.gz
    tar zxvf atlas_3.10.2_linux_x64.tar.gz
    mv lib $INSTALL_DIR
    command -v gfortran || return 0
    BUNDLED_LGF_CANON=$INSTALL_DIR/lib/libgfortran.so.3.0.0
    BUNDLED_LGF_VERS=`objdump -p $BUNDLED_LGF_CANON | grep GFORTRAN_1 | sed -r 's/.*GFORTRAN_1\.([0-9])+/\1/' | sort -n | tail -1`
    echo 'program test; end program test' > test.f90
    gfortran -o test test.f90
    LGF=`ldd test | grep libgfortran | awk '{print $3}'`
    LGF_CANON=`readlink -f $LGF`
    LGF_VERS=`objdump -p $LGF_CANON | grep GFORTRAN_1 | sed -r 's/.*GFORTRAN_1\.([0-9])+/\1/' | sort -n | tail -1`
    if [ $LGF_VERS -gt $BUNDLED_LGF_VERS ]; then
        cp -p $BUNDLED_LGF_CANON ${BUNDLED_LGF_CANON}.bundled
        cp -p $LGF_CANON $BUNDLED_LGF_CANON
    fi
    popd
    rm -rf $wd/*
    rmdir $wd
    export ATLAS_LIB_DIR=$INSTALL_DIR/lib
    export ATLAS_INCLUDE_DIR=$INSTALL_DIR/include
    export ATLAS_BLAS_LIB_DIR=$INSTALL_DIR/lib/atlas
    export ATLAS_LAPACK_LIB_DIR=$INSTALL_DIR/lib/atlas
    export ATLAS_ROOT_PATH=$INSTALL_DIR
    export LD_LIBRARY_PATH=$INSTALL_DIR/lib:$LD_LIBRARY_PATH
    export LD_LIBRARY_PATH=$INSTALL_DIR/lib/atlas:$LD_LIBRARY_PATH
    # Numpy 1.9.2
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://pypi.python.org/packages/ce/a8/bce42709c423f044bc60038922d81ac0be5042d025ea9e3d4734341eef83/numpy-1.9.2.tar.gz
    tar -zxvf numpy-1.9.2.tar.gz
    cd numpy-1.9.2
    cat > site.cfg <<EOF
[DEFAULT]
library_dirs = $ATLAS_LIB_DIR
include_dirs = $ATLAS_INCLUDE_DIR
[blas_opt]
libraries = blas, atlas
[lapack_opt]
libraries = lapack, atlas
EOF
    export PYTHONPATH=$PYTHONPATH:$INSTALL_DIR/lib/python2.7
    export ATLAS=$ATLAS_ROOT_PATH
    python setup.py install --install-lib $INSTALL_DIR/lib/python2.7 --install-scripts $INSTALL_DIR/bin
    popd
    rm -rf $wd/*
    rmdir $wd
    # Remaining Python packages
    ##install_python_package $INSTALL_DIR numpy 1.9 \
	##https://pypi.python.org/packages/ce/a8/bce42709c423f044bc60038922d81ac0be5042d025ea9e3d4734341eef83/numpy-1.9.2.tar.gz \
	##numpy-1.9.2
    install_python_package $INSTALL_DIR Bottleneck 1.0.0 \
	https://pypi.python.org/packages/source/B/Bottleneck/Bottleneck-1.0.0.tar.gz \
	Bottleneck-1.0.0
    install_python_package $INSTALL_DIR pytz 2015.7 \
	https://pypi.python.org/packages/source/p/pytz/pytz-2015.7.tar.gz \
	pytz-2015.7
    install_python_package $INSTALL_DIR six 1.10.0 \
	https://pypi.python.org/packages/source/s/six/six-1.10.0.tar.gz \
	six-1.10.0
    install_python_package $INSTALL_DIR dateutil 2.4.2 \
	https://pypi.python.org/packages/source/p/python-dateutil/python-dateutil-2.4.2.tar.gz \
	python-dateutil-2.4.2
    install_python_package $INSTALL_DIR pandas 0.16 \
	https://pypi.python.org/packages/source/p/pandas/pandas-0.16.2.tar.gz \
	pandas-0.16.2
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup pandas/0.16
echo Setting up pandas 0.16
#if [ -f $1/python/2.7.10/env.sh ] ; then
#   . $1/python/2.7.10/env.sh
#fi
export PATH=$INSTALL_DIR/bin:\$PATH
export PYTHONPATH=$INSTALL_DIR:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib/python2.7:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib/python2.7/site-packages:\$PYTHONPATH
export LD_LIBRARY_PATH=$ATLAS_LIB_DIR:\$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$ATLAS_LIB_DIR/atlas::\$LD_LIBRARY_PATH
#
EOF
}
function install_pyvcf_0_6_8() {
    echo Installing PyVCF 0.16
    INSTALL_DIR=$1/pyvcf/0.6.8
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    install_python_package $INSTALL_DIR PyVCF 0.6.8 \
	https://pypi.python.org/packages/20/b6/36bfb1760f6983788d916096193fc14c83cce512c7787c93380e09458c09/PyVCF-0.6.8.tar.gz \
	PyVCF-0.6.8
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup PyVCF/0.6.8
echo Setting up PyVCF 0.6.8
#if [ -f $1/python/2.7.10/env.sh ] ; then
#   . $1/python/2.7.10/env.sh
#fi
export PATH=$INSTALL_DIR/bin:\$PATH
export PYTHONPATH=$INSTALL_DIR:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib/python2.7:\$PYTHONPATH
export PYTHONPATH=$INSTALL_DIR/lib/python2.7/site-packages:\$PYTHONPATH
#
EOF
}
function install_r_3_2_1() {
    echo Installing R 3.2.1
    INSTALL_DIR=$1/R/3.2.1
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q http://cran.rstudio.com/src/base/R-3/R-3.2.1.tar.gz
    tar xzf R-3.2.1.tar.gz
    cd R-3.2.1
    ./configure --prefix=$INSTALL_DIR --with-cairo --without-x --enable-R-shlib --disable-R-framework --libdir=$INSTALL_DIR/lib >$INSTALL_DIR/INSTALLATION.log 2>&1
    make >>$INSTALL_DIR/INSTALLATION.log 2>&1
    make install >>$INSTALL_DIR/INSTALLATION.log 2>&1
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup R/3.2.1
echo Setting up R 3.2.1
export PATH=$INSTALL_DIR/bin:\$PATH
export LD_LIBRARY_PATH=$INSTALL_DIR/lib:\$LD_LIBRARY_PATH
EOF
}
function install_r_3_3_0() {
    echo Installing R 3.3.0
    INSTALL_DIR=$1/R/3.3.0
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    # Install zlib 1.2.5 (R 3.3.0 needs >= 1.2.5)
    local zlib_version=1.2.5
    wget -q http://www.zlib.net/fossils/zlib-${zlib_version}.tar.gz
    tar xzf zlib-${zlib_version}.tar.gz
    cd zlib-${zlib_version}
    ./configure --prefix=$INSTALL_DIR >$INSTALL_DIR/INSTALLATION.log 2>&1
    make >>$INSTALL_DIR/INSTALLATION.log 2>&1
    make install >>$INSTALL_DIR/INSTALLATION.log 2>&1
    cd ..
    # Install bzip2 1.0.6 (R 3.3.0 needs >= 1.0.6)
    local bz2_version=1.0.6
    wget -q http://www.bzip.org/1.0.6/bzip2-${bz2_version}.tar.gz
    tar xzf bzip2-${bz2_version}.tar.gz
    cd bzip2-${bz2_version}
    make -f Makefile-libbz2_so >>$INSTALL_DIR/INSTALLATION.log 2>&1
    make install PREFIX=$INSTALL_DIR >>$INSTALL_DIR/INSTALLATION.log 2>&1
    cp -f libbz2.so.${bz2_version} $INSTALL_DIR/lib
    cd ..
    # Install XZ utils
    local xz_version=5.2.3
    wget -q http://tukaani.org/xz/xz-${xz_version}.tar.gz
    tar xzf xz-${xz_version}.tar.gz
    cd xz-${xz_version}
    ./configure --prefix=$INSTALL_DIR >$INSTALL_DIR/INSTALLATION.log 2>&1
    make >>$INSTALL_DIR/INSTALLATION.log 2>&1
    make install >>$INSTALL_DIR/INSTALLATION.log 2>&1
    cd ..
    # Install PCRE 8.10 with UTF-8 support (R 3.3.0 needs >= 8.10)
    local pcre_version=8.10
    wget -q https://ftp.pcre.org/pub/pcre/pcre-${pcre_version}.tar.gz
    tar xzf pcre-${pcre_version}.tar.gz
    cd pcre-${pcre_version}
    ./configure --enable-utf8 --prefix=$INSTALL_DIR >$INSTALL_DIR/INSTALLATION.log 2>&1
    make >>$INSTALL_DIR/INSTALLATION.log 2>&1
    make install >>$INSTALL_DIR/INSTALLATION.log 2>&1
    cd ..
    # Install curl 7.28.0 (R 3.3.0 needs >= 7.28.0)
    local curl_version=7.28.0
    wget -q https://curl.haxx.se/download/curl-${curl_version}.tar.gz
    tar xzf curl-${curl_version}.tar.gz
    cd curl-${curl_version}
    ./configure --prefix=$INSTALL_DIR >$INSTALL_DIR/INSTALLATION.log 2>&1
    make >>$INSTALL_DIR/INSTALLATION.log 2>&1
    make install >>$INSTALL_DIR/INSTALLATION.log 2>&1
    cd ..
    # Install R
    wget -q http://cran.rstudio.com/src/base/R-3/R-3.3.0.tar.gz
    tar xzf R-3.3.0.tar.gz
    cd R-3.3.0
    /bin/bash <<EOF
export PATH=$INSTALL_DIR/bin:$PATH
export LD_LIBRARY_PATH=$INSTALL_DIR/lib:$LD_LIBRARY_PATH
export CFLAGS="-I$INSTALL_DIR/include"
export LDFLAGS="-L$INSTALL_DIR/lib"
./configure --prefix=$INSTALL_DIR --with-cairo --without-x --enable-R-shlib --disable-R-framework --libdir=$INSTALL_DIR/lib >>$INSTALL_DIR/INSTALLATION.log 2>&1
make >>$INSTALL_DIR/INSTALLATION.log 2>&1
make install >>$INSTALL_DIR/INSTALLATION.log 2>&1
EOF
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup R/3.3.0
echo Setting up R 3.3.0
export PATH=$INSTALL_DIR/bin:\$PATH
export LD_LIBRARY_PATH=$INSTALL_DIR/lib:\$LD_LIBRARY_PATH
EOF
}
function install_r_package() {
    echo Installing $2 under $1 for R $3
    echo $(pwd)
    local r_version=$3
    if [ ! -f $1/../../R/$r_version/env.sh ] ; then
	echo Missing $1/../../R/$r_version/env.sh >&2
	exit 1
    fi
    local install_dir=$1
    mkdir -p $install_dir
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    if [ ! -z "$(echo $2 | grep ^http)" ] ; then
	echo Downloading $2...
	wget -q $2
	if [ ! -f "$(basename $2)" ] ; then
	    echo FAILED to download $(basename $2) >&2
	    exit 1
	fi
    fi
    local source_package="$(echo $2 | grep .tar.gz$)"
    if [ ! -z "$source_package" ] ; then
	echo Installing source package $(basename $2)...
	/bin/bash <<EOF
. $1/../../R/$r_version/env.sh &&  \
export R_LIBS=$install_dir:$R_LIBS && \
R CMD INSTALL -l $install_dir $(basename $2) >>$install_dir/INSTALLATION.log 2>&1
EOF
    else
	echo Installing CRAN package $(basename $2)...
	/bin/bash <<EOF
. $1/../../R/$r_version/env.sh &&  \
export R_LIBS=$install_dir:$R_LIBS && \
R --vanilla >>$install_dir/INSTALLATION.log 2>&1 <<cran
install.packages("$2",lib="$install_dir",repos="http://cran.r-project.org")
q()
cran
EOF
    fi
    popd
    rm -rf $wd/*
    rmdir $wd
}
function install_bioc_package() {
    echo Installing $2 under $1 for R $3
    echo $(pwd)
    local r_version=$3
    if [ ! -f $1/../../R/$r_version/env.sh ] ; then
	echo Missing $1/../../R/$r_version/env.sh >&2
	exit 1
    fi
    local install_dir=$1
    mkdir -p $install_dir
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    /bin/bash <<EOF
. $1/../../R/$r_version/env.sh &&  \
export R_LIBS=$install_dir:$R_LIBS && \
R --vanilla  >>$install_dir/INSTALLATION.log 2>&1 <<bioc
source("http://bioconductor.org/biocLite.R")
biocLite()
biocLite("$2",lib="$install_dir")
q()
bioc
EOF
    popd
    rm -rf $wd/*
    rmdir $wd
}
function install_dplyr() {
    echo Installing dplyr
    INSTALL_DIR=$1/dplyr/0.5.0
    R_VERSION=$2
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    packages=\
"https://cran.r-project.org/src/contrib/assertthat_0.1.tar.gz \
 https://cran.r-project.org/src/contrib/R6_2.1.3.tar.gz \
 https://cran.r-project.org/src/contrib/Rcpp_0.12.7.tar.gz \
 https://cran.r-project.org/src/contrib/magrittr_1.5.tar.gz \
 https://cran.r-project.org/src/contrib/lazyeval_0.2.0.tar.gz \
 https://cran.r-project.org/src/contrib/DBI_0.5-1.tar.gz \
 https://cran.r-project.org/src/contrib/tibble_1.2.tar.gz \
 https://cran.r-project.org/src/contrib/BH_1.60.0-2.tar.gz \
 https://cran.r-project.org/src/contrib/dplyr_0.5.0.tar.gz"
    for package in $packages ; do
	install_r_package $INSTALL_DIR $package $R_VERSION
    done
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup dplyr/0.5.0
echo Setting up dplyr 0.5.0 for R $R_VERSION
if [ -f $1/R/$R_VERSION/env.sh ] ; then
   . $1/R/$R_VERSION/env.sh
fi
export R_LIBS=$INSTALL_DIR:\$R_LIBS
#
EOF
}
function install_coloc() {
    echo Installing coloc
    INSTALL_DIR=$1/coloc/2.3-1
    R_VERSION=$2
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    packages=\
"https://cran.r-project.org/src/contrib/colorspace_1.2-6.tar.gz \
 https://cran.r-project.org/src/contrib/leaps_2.9.tar.gz \
 https://cran.r-project.org/src/contrib/DEoptimR_1.0-6.tar.gz \
 https://cran.r-project.org/src/contrib/robustbase_0.92-6.tar.gz \
 https://cran.r-project.org/src/contrib/inline_0.3.14.tar.gz \
 https://cran.r-project.org/src/contrib/mvtnorm_1.0-5.tar.gz \
 https://cran.r-project.org/src/contrib/pcaPP_1.9-60.tar.gz \
 https://cran.r-project.org/src/contrib/rrcov_1.4-3.tar.gz \
 https://cran.r-project.org/src/contrib/BMA_3.18.6.tar.gz \
 https://cran.r-project.org/src/contrib/coloc_2.3-1.tar.gz"
    for package in $packages ; do
	install_r_package $INSTALL_DIR $package $R_VERSION
    done
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup coloc/2.3-1
echo Setting up coloc 2.3-1 for R $R_VERSION
if [ -f $1/R/$R_VERSION/env.sh ] ; then
   . $1/R/$R_VERSION/env.sh
fi
export R_LIBS=$INSTALL_DIR:\$R_LIBS
#
EOF
}
function install_readr() {
    echo Installing readr
    INSTALL_DIR=$1/readr/1.0.0
    R_VERSION=$2
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    packages=\
"https://cran.r-project.org/src/contrib/Rcpp_0.12.7.tar.gz \
 https://cran.r-project.org/src/contrib/curl_2.1.tar.gz \
 https://cran.r-project.org/src/contrib/assertthat_0.1.tar.gz \
 https://cran.r-project.org/src/contrib/lazyeval_0.2.0.tar.gz \
 https://cran.r-project.org/src/contrib/tibble_1.2.tar.gz \
 https://cran.r-project.org/src/contrib/hms_0.2.tar.gz \
 https://cran.r-project.org/src/contrib/R6_2.1.3.tar.gz \
 https://cran.r-project.org/src/contrib/BH_1.60.0-2.tar.gz \
 https://cran.r-project.org/src/contrib/readr_1.0.0.tar.gz"
    for package in $packages ; do
	install_r_package $INSTALL_DIR $package $R_VERSION
    done
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup readr/1.0.0
echo Setting up readr 1.0.0 for R $R_VERSION
if [ -f $1/R/$R_VERSION/env.sh ] ; then
   . $1/R/$R_VERSION/env.sh
fi
export R_LIBS=$INSTALL_DIR:\$R_LIBS
#
EOF
}
function install_tidyr() {
    echo Installing tidyr
    INSTALL_DIR=$1/tidyr/0.6.0
    R_VERSION=$2
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    packages=\
"https://cran.r-project.org/src/contrib/stringi_1.1.2.tar.gz \
 https://cran.r-project.org/src/contrib/R6_2.1.3.tar.gz \
 https://cran.r-project.org/src/contrib/Rcpp_0.12.7.tar.gz \
 https://cran.r-project.org/src/contrib/magrittr_1.5.tar.gz \
 https://cran.r-project.org/src/contrib/lazyeval_0.2.0.tar.gz \
 https://cran.r-project.org/src/contrib/DBI_0.5-1.tar.gz \
 https://cran.r-project.org/src/contrib/assertthat_0.1.tar.gz \
 https://cran.r-project.org/src/contrib/tibble_1.2.tar.gz \
 https://cran.r-project.org/src/contrib/BH_1.60.0-2.tar.gz \
 https://cran.r-project.org/src/contrib/dplyr_0.5.0.tar.gz \
 https://cran.r-project.org/src/contrib/tidyr_0.6.0.tar.gz"
    for package in $packages ; do
	install_r_package $INSTALL_DIR $package $R_VERSION
    done
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup tidyr/0.6.0
echo Setting up tidyr 0.6.0 for R $R_VERSION
if [ -f $1/R/$R_VERSION/env.sh ] ; then
   . $1/R/$R_VERSION/env.sh
fi
export R_LIBS=$INSTALL_DIR:\$R_LIBS
#
EOF
}
function install_stringr() {
    echo Installing stringr
    INSTALL_DIR=$1/stringr/1.1.0
    R_VERSION=$2
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    packages=\
"https://cran.r-project.org/src/contrib/stringi_1.1.2.tar.gz \
 https://cran.r-project.org/src/contrib/magrittr_1.5.tar.gz \
 https://cran.r-project.org/src/contrib/stringr_1.1.0.tar.gz"
    for package in $packages ; do
	install_r_package $INSTALL_DIR $package $R_VERSION
    done
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup stringr/1.1.0
echo Setting up stringr 1.1.0 for R $R_VERSION
if [ -f $1/R/$R_VERSION/env.sh ] ; then
   . $1/R/$R_VERSION/env.sh
fi
export R_LIBS=$INSTALL_DIR:\$R_LIBS
#
EOF
}
function install_optparse() {
    echo Installing optparse
    INSTALL_DIR=$1/optparse/1.3.2
    R_VERSION=$2
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    packages=\
"https://cran.r-project.org/src/contrib/getopt_1.20.0.tar.gz \
 https://cran.r-project.org/src/contrib/optparse_1.3.2.tar.gz"
    for package in $packages ; do
	install_r_package $INSTALL_DIR $package $R_VERSION
    done
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup optparse/1.3.2
echo Setting up optparse 1.3.2 for R $R_VERSION
if [ -f $1/R/$R_VERSION/env.sh ] ; then
   . $1/R/$R_VERSION/env.sh
fi
export R_LIBS=$INSTALL_DIR:\$R_LIBS
#
EOF
}
function install_gviz() {
    echo Installing Gviz
    INSTALL_DIR=$1/gviz/1.16.5
    R_VERSION=$2
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    packages="Gviz"
    for package in $packages ; do
	install_bioc_package $INSTALL_DIR $package $R_VERSION
    done
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup Gviz/1.16.5
echo Setting up Gviz 1.16.1 for R $R_VERSION
if [ -f $1/R/$R_VERSION/env.sh ] ; then
   . $1/R/$R_VERSION/env.sh
fi
export R_LIBS=$INSTALL_DIR:\$R_LIBS
#
EOF
}
function install_biomart() {
    echo Installing biomaRt
    INSTALL_DIR=$1/biomart/2.28.0
    R_VERSION=$2
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    packages="biomaRt"
    for package in $packages ; do
	install_bioc_package $INSTALL_DIR $package $R_VERSION
    done
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup biomaRt/2.28.0
echo Setting up biomaRt 2.28.0 for R $R_VERSION
if [ -f $1/R/$R_VERSION/env.sh ] ; then
   . $1/R/$R_VERSION/env.sh
fi
export R_LIBS=$INSTALL_DIR:\$R_LIBS
#
EOF
}
function install_craft_R_dependencies() {
    echo Installing R dependencies for CRAFT-GP
    local r_version=$2
    echo Targetting R version: $r_version
    if [ -f $1/craft_gp_R/default/env.sh ] ; then
	return
    fi
    local version=$(date +%Y%m%d-%H%M%S)
    echo Timestamp for version: $version
    local install_dir=$1/craft_gp_R/$version
    mkdir -p $install_dir
    cran_packages=\
"dplyr
 coloc
 readr
 tidyr
 stringr
 optparse"
    for package in $cran_packages ; do
	install_r_package $install_dir $package $r_version
    done
    bioc_packages="Gviz"
    for package in $bioc_packages ; do
	install_bioc_package $install_dir $package $r_version
    done
    # Make setup file
    cat > $install_dir/env.sh <<EOF
#!/bin/sh
# Source this to setup CRAFT-GP R dependencies/$version
echo Setting up CRAFT-GP R dependencies $version for R $r_version
if [ -f $1/R/$r_version/env.sh ] ; then
   . $1/R/$r_version/env.sh
fi
export R_LIBS=$install_dir:\$R_LIBS
#
EOF
    # Make this the default version
    if [ -e $install_dir/../default ] ; then
	echo Removing old link to default
	rm -f $install_dir/../default
    fi
    echo Making symlink for default version
    ln -s $version $install_dir/../default
}
function install_tabix_0_2_6() {
    echo Installing tabix
    INSTALL_DIR=$1/tabix/0.2.6
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    mkdir -p $INSTALL_DIR/bin
    mkdir -p $INSTALL_DIR/lib
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q https://sourceforge.net/projects/samtools/files/tabix/tabix-0.2.6.tar.bz2
    tar xjf tabix-0.2.6.tar.bz2
    cd tabix-0.2.6
    make 2>&1 >$INSTALL_DIR/INSTALLATION.log
    mv tabix $INSTALL_DIR/bin
    mv tabix.py $INSTALL_DIR/bin
    mv bgzip $INSTALL_DIR/bin
    mv libtabix.a $INSTALL_DIR/lib
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup tabix/0.2.6
echo Setting up tabix 0.2.6
export PATH=$INSTALL_DIR/bin:\$PATH
#
EOF
}
function install_perl_5_18_4() {
    # Perl 5.18.4
    local perl_version=5.18.4
    echo Installing Perl $perl_version
    local install_dir=$1/perl/$perl_version
    if [ -f $install_dir/env.sh ] ; then
	return
    fi
    mkdir -p $install_dir
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q http://www.cpan.org/src/5.0/perl-${perl_version}.tar.gz
    tar xzf perl-${perl_version}.tar.gz
    cd perl-${perl_version}
    ./Configure -des -Dprefix=$install_dir -D startperl='#!/usr/bin/env perl' >$install_dir/INSTALLATION.log 2>&1
    make install >>$install_dir/INSTALLATION.log 2>&1
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $1/perl/${perl_version}/env.sh <<EOF
#!/bin/sh
# Source this to setup perl/${perl_version}
echo Setting up perl ${perl_version}
export PATH=$install_dir/bin:\$PATH
#
EOF
}
function install_perl_package() {
    echo Installing $2 under $1
    echo $(pwd)
    local install_dir=$1
    mkdir -p $install_dir/lib/perl5
    local wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    wget -q -L https://cpanmin.us/ -O cpanm
    chmod +x cpanm
    /bin/bash <<EOF
. $install_dir/../../perl/$PERL_VERSION/env.sh && \
export PATH=$install_dir/bin:\$PATH PERL5LIB=$install_dir/lib/perl5:$install_dir/lib/perl5/x86_64-linux:\$PERL5LIB && \
./cpanm -l $install_dir $2 >>$install_dir/INSTALLATION.log 2>&1
EOF
    popd
    rm -rf $wd/*
    rmdir $wd
}
function install_variant_effect_predictor_84() {
    echo Installing VEP 84
    INSTALL_DIR=$1/variant_effect_predictor/84
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    if [ ! -f $1/tabix/0.2.6/env.sh ] ; then
	echo Missing $1/tabix/0.2.6/env.sh >&2
	exit 1
    fi
    if [ ! -f $1/perl/$PERL_VERSION/env.sh ] ; then
	echo Missing $1/perl/$PERL_VERSION/env.sh >&2
	exit 1
    fi
    mkdir -p $INSTALL_DIR
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    # Install generic MySQL code
    wget -q https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz
    tar xzf mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz
    cd mysql-5.7.17-linux-glibc2.5-x86_64
    for item in $(ls -c1 .) ; do
	echo Examining $item
	if [ -d $item ] && [ ! -e "$INSTALL_DIR/$item" ] ; then
	    echo Copying $item
	    /bin/mv $item $INSTALL_DIR
	fi
    done
    cd ..
    rm -rf mysql-5.7.17-linux-glibc2.5-x86_64.tar.gz
    # Create any missing target dirs
    for d in bin lib ; do
	if [ ! -d "$INSTALL_DIR/$d" ] ; then
	    mkdir -p $INSTALL_DIR/$d
	fi
    done
    install_perl_package $INSTALL_DIR "File::Copy::Recursive"
    install_perl_package $INSTALL_DIR "Archive::Extract"
    install_perl_package $INSTALL_DIR "Archive::Zip"
    install_perl_package $INSTALL_DIR "DBI"
    install_perl_package $INSTALL_DIR "LWP::Protocol::https"
    install_perl_package $INSTALL_DIR "JSON"
    install_perl_package $INSTALL_DIR "DBD::mysql"
    install_perl_package $INSTALL_DIR "IPC::Cmd"
    install_perl_package $INSTALL_DIR "Params::Check"
    install_perl_package $INSTALL_DIR "Locale::Maketext::Simple"
    wget -q https://github.com/Ensembl/ensembl-tools/archive/release/84.zip
    unzip -qq 84.zip
    cd ensembl-tools-release-84
    /bin/bash <<EOF
. $1/tabix/0.2.6/env.sh
. $1/perl/$PERL_VERSION/env.sh
export PATH=$INSTALL_DIR/bin:$INSTALL_DIR/lib/perl5/htslib:\$PATH
export PERL5LIB=$INSTALL_DIR/lib/perl5:\$PERL5LIB
export PERL5LIB=$INSTALL_DIR/lib/perl5/Plugins:\$PERL5LIB
export PERL5LIB=$INSTALL_DIR/lib/perl5/x86_64-linux-thread-multi:\$PERL5LIB
export LD_LIBRARY_PATH=$INSTALL_DIR/lib:\$LD_LIBRARY_PATH
yes | perl scripts/variant_effect_predictor/INSTALL.pl \
	 --AUTO a \
	 --DESTDIR $INSTALL_DIR/lib/perl5 \
         --NO_HTSLIB >>$INSTALL_DIR/INSTALLATION.log 2>&1
EOF
    for s in convert_cache.pl filter_vep.pl gtf2vep.pl variant_effect_predictor.pl ; do
	mv scripts/variant_effect_predictor/$s $INSTALL_DIR/bin
    done
    /bin/bash <<EOF
. $1/perl/$PERL_VERSION/env.sh
export PATH=$INSTALL_DIR/bin:$INSTALL_DIR/lib/perl5/htslib:\$PATH
export PERL5LIB=$INSTALL_DIR/lib/perl5:\$PERL5LIB
export PERL5LIB=$INSTALL_DIR/lib/perl5/Plugins:\$PERL5LIB
export PERL5LIB=$INSTALL_DIR/lib/perl5/x86_64-linux-thread-multi:\$PERL5LIB
export LD_LIBRARY_PATH=$INSTALL_DIR/lib:\$LD_LIBRARY_PATH
yes | perl scripts/variant_effect_predictor/INSTALL.pl \
	 --AUTO p \
	 --DESTDIR $INSTALL_DIR/lib/perl5 \
         --CACHEDIR $INSTALL_DIR/lib/perl5 \
         --NO_HTSLIB \
         --PLUGINS CADD >>$INSTALL_DIR/INSTALLATION.log 2>&1
EOF
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup VEP/84
echo Setting up VEP 84
if [ -f $1/tabix/0.2.6/env.sh ] ; then
   . $1/tabix/0.2.6/env.sh
fi
export PATH=$INSTALL_DIR/bin:\$PATH
export PERL5LIB=$INSTALL_DIR/lib/perl5:\$PERL5LIB
export PERL5LIB=$INSTALL_DIR/lib/perl5/Plugins:\$PERL5LIB
export PERL5LIB=$INSTALL_DIR/lib/perl5/x86_64-linux-thread-multi:\$PERL5LIB
export LD_LIBRARY_PATH=$INSTALL_DIR/lib:\$LD_LIBRARY_PATH
#
EOF
}
function install_craft_gp() {
    echo Installing CRAFT-GP
    INSTALL_DIR=$1/CRAFT-GP/0.0.0
    if [ -f $INSTALL_DIR/env.sh ] ; then
	return
    fi
    mkdir -p $INSTALL_DIR
    wd=$(mktemp -d)
    echo Moving to $wd
    pushd $wd
    ### Latest canonical version from CRAFT-GP github
    wget -q https://github.com/johnbowes/CRAFT-GP/archive/master.tar.gz
    tar xzf master.tar.gz
    cd CRAFT-GP-master/
    /bin/mv scripts $INSTALL_DIR/scripts
    /bin/mv source_data $INSTALL_DIR/source_data
    cd ..
    #wget -q https://github.com/chr1swallace/random-functions/raw/master/R/abf.R
    # Download the patched version from John Bowes
    wget -q http://bartzabel.ls.manchester.ac.uk/Pete/ZsPKfe21H3/CRAFT-GP/abf-patched.R
    /bin/mv abf-patched.R $INSTALL_DIR/scripts/abf.R
    popd
    rm -rf $wd/*
    rmdir $wd
    # Make setup file
    cat > $INSTALL_DIR/env.sh <<EOF
#!/bin/sh
# Source this to setup CRAFT-GP/0.0.0
echo Setting up CRAFT-GP 0.0.0
export CRAFT_GP_SCRIPTS=$INSTALL_DIR/scripts
export CRAFT_GP_DATA=$INSTALL_DIR/source_data
EOF
}
##########################################################
# Main script starts here
##########################################################
# Fetch top-level installation directory from command line
TOP_DIR=$1
if [ -z "$TOP_DIR" ] ; then
    echo Usage: $(basename $0) DIR
    exit
fi
if [ -z "$(echo $TOP_DIR | grep ^/)" ] ; then
    TOP_DIR=$(pwd)/$TOP_DIR
fi
if [ ! -d "$TOP_DIR" ] ; then
    mkdir -p $TOP_DIR
fi
# Install dependencies
##install_ruby_1_9 $TOP_DIR
install_ruby_2_2_3 $TOP_DIR
##install_python_2_7_10 $TOP_DIR
install_pandas_0_16 $TOP_DIR
install_pyvcf_0_6_8 $TOP_DIR
##install_r_3_2_1 $TOP_DIR
install_r_3_3_0 $TOP_DIR
# R version for R dependencies
R_VERSION=3.3.0
install_craft_R_dependencies $TOP_DIR $R_VERSION
#install_dplyr $TOP_DIR $R_VERSION
#install_coloc $TOP_DIR $R_VERSION
#install_readr $TOP_DIR $R_VERSION
#install_tidyr $TOP_DIR $R_VERSION
#install_stringr $TOP_DIR $R_VERSION
#install_optparse $TOP_DIR $R_VERSION
#install_gviz $TOP_DIR $R_VERSION
##install_biomart $TOP_DIR $R_VERSION
install_tabix_0_2_6 $TOP_DIR
install_perl_5_18_4 $TOP_DIR
PERL_VERSION=5.18.4
install_variant_effect_predictor_84 $TOP_DIR
install_craft_gp $TOP_DIR
##
#
