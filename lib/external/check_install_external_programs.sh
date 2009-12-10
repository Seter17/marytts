# HMMVoice creation for MARY 4.0 beta

# Exit on all errors
set -e
# Trap exit
trap trap_exit_handler EXIT


# Handle exit trap
function trap_exit_handler() {
    # Backup exit status if you're interested...
    local exit_status=$?
    # Change value of $?
    true
    #echo $?
    #echo trap_handler $exit_status
} # trap_exit_handler()


if [ $# -lt 1 ] ; then
  echo ""
  echo "check_programs.sh: check the neccessary programs (and versions) to run the HTS-HTK demo for MARY 4.0 beta"
  echo "Usage: $0 [options:-check|-install][paths (if not in PATH): path-to-awk|path-to-perl|path-to-tclsh|path-to-bc|path-to-sox|path-to-htk|path-to-htsengine|path-to-sptk]"
  echo "     options:"
  echo "       -check  : just check programs in PATH or in the paths provided by the user"
  echo "       -install: check programs in PATH or in the paths provided by the user and try to install the missing ones"
  echo ""
  exit  
fi

#MARY_BASE
external_dir="`dirname "$0"`"
MARY_BASE="`(cd "$external_dir"/../.. ; pwd)`"
echo "MARY_BASE=$MARY_BASE"

PATH=$MARY_BASE/lib/external/bin:$PATH

# Add the paths provided to the general $PATH
for p in $@ 
do
  if [ $p =  "-check" ] || [ $p =  "-install" ] ; then
    option=$p
    echo "option=$p"
  else 
    PATH=$p:$PATH
  fi
done
echo "PATH=$PATH"
echo "OPTION = $option"


# The following programs will be checked:
# awk, perl,  tclsh and snack, bc, sox, htk, hts_engine, sptk
# If any of these programs exist then the programs terminates suggesting how it can be installed

#################awk
if which awk > /dev/null; then
   awkProg=`which awk`
   awkPath=`dirname $awkProg`
   echo "awk: $awkProg"
   echo "ok"
   echo
else
   echo "awk: was not found"
   if [ $option = "-install" ] ; then
     echo "suggested commands:"
     echo "  sudo apt-get install awk"
     echo "The previous command will be executed, it requires administrator privileges"
     echo "continue (y/n)?"
     read choice
     if [ $choice = "y" ] ; then
       sudo apt-get install awk 
     else
       echo "awk: is not installed"
     fi
   else
     echo "awk: is not installed"
   fi
fi

################## perl
if which perl > /dev/null; then
   perlProg=`which perl`
   perlPath=`dirname $perlProg`
   echo "perl: $perlProg"
   echo "ok"
   echo
else
   echo "perl: was not found"
   if [ $option = "-install" ] ; then
     echo "suggested commands:"
     echo "  sudo apt-get install perl"
     echo "The previous command will be executed, it requires administrator privileges"
     echo "continue (y/n)?"
     read choice
     if [ $choice = "y" ] ; then
       sudo apt-get install perl 
     else
       echo "perl: is not installed"
     fi
   else
     echo "perl: is not installed"
   fi
fi


################# tclsh and snack
if which tclsh > /dev/null; then
    tclshProg=`which tclsh`    
    echo "tclsh: $tclshProg"
    echo "package require snack" > tmp.tcl
    echo "snack::sound s" >> tmp.tcl
    if `$tclshProg tmp.tcl` > /dev/null; then
       rm tmp.tcl
       tclshPath=`dirname $tclshProg`
       echo "tclsh was found and supports snack"
       echo "ok"
       echo
    else
      echo "tclsh installed but it does not support snack." 
      echo "snack can be download from: http://www.speech.kth.se/snack/dist/snack2.2.10-linux.tar.gz"
      echo "unpack it and then copy the directory to your ../tclsh/lib directory"
      if [ $option = "-install" ] ; then
        echo "suggested commands:"
        echo "  sudo apt-get install libsnack2"
        echo "The previous command will be executed, it requires administrator privileges"
        echo "continue (y/n)?"
        read choice
        if [ $choice = "y" ] ; then
          sudo apt-get install libsnack2
        else
          echo "tcl was found but it does not support snack"
        fi
      else
        echo "tcl was found but it does not support snack"
      fi
    fi
else
    echo "tclsh does not exist"
    if [ $option = "-install" ] ; then
      echo "suggested commands:"
      echo "  sudo apt-get install tclsh"
      echo "  sudo apt-get install libsnack2"
      echo "The previous commands will be executed, it requires administrator privileges"
      echo "continue (y/n)?"
      read choice
      if [ $choice = "y" ] ; then
        sudo apt-get install tclsh        
        sudo apt-get install libsnack2
      else
        echo "tclsh: is not installed"
      fi
    else
      echo "tclsh: is not installed"
    fi
fi



################## bc
if which bc > /dev/null; then
   bcProg=`which bc`
   echo "bc: $bcProg" 
   # also check the math lib
   count=`echo "0.005 * 1600" | bc -l`
   echo "bc: checking -l (mathlib)"
   if [ $count = 8.000 ]; then 
     bcPath=`dirname $bcProg`    
     echo "ok"
     echo
   else
     echo "Missing mathlib for running bc, install a newer version of bc"
     echo "It can be installed with the command:"
     echo "  sudo apt-get install bc"
     echo "The previous command will be executed, it requires administrator privileges"
     echo "continue (y/n)?"
     read choice
     if [ $choice = "y" ] ; then
       sudo apt-get install bc
     else
       echo "bc: is not installed"
     fi
   fi 
else
   echo "bc: does not exist"
   echo "It can be installed with the command:"
   echo "  sudo apt-get install bc"
   echo "The previous command will be executed, it requires administrator privileges"
   echo "continue (y/n)?"
   read choice
   if [ $choice = "y" ] ; then
     sudo apt-get install bc
   else
     echo "bc: is not installed"
   fi
fi


################ sox
if which sox > /dev/null; then
    soxProg=`which sox`
    # check sox version
    soxVer=`sox --version | awk '{print substr($3,2,2)}'`
    if [ $soxVer -ge 13 ]; then
      soxPath=`dirname $soxProg`
      echo "sox: $soxProg"
      echo "ok"
      echo
    else
      echo "sox: $soxProg"
      echo "sox installed but probably an older version, please install sox >= v13"
      echo "It can be installed with the command:"
      echo "  sudo apt-get install sox"
      echo "The previous command will be executed, it requires administrator privileges"
      echo "continue (y/n)?"
      read choice
      if [ $choice = "y" ] ; then
        sudo apt-get install sox 
      else
        echo "sox: is not installed"
      fi
    fi
else
    echo "sox: does not exist"
    echo "It can be installed with the command:"
    echo "  sudo apt-get install sox"
    echo "The previous command will be executed, it requires administrator privileges"
    echo "continue (y/n)?"
    read choice
    if [ $choice = "y" ] ; then
      sudo apt-get install sox 
    else
      echo "sox: is not installed"
    fi
fi


################# HTK
if which HHEd > /dev/null; then
    echo "HTK HHEd exists"
    hhedProg=`which HHEd`
    # Check HTK version and if it is patched with HTS
    htkVer=`$hhedProg -V | grep HHEd | awk '{print $2}'`
    echo "HTK version: $htkVer" 
    # Check if htk is patched, if so HHEd has to have a CM command which is:
    # CM directory         - Convert models to pdf for speech synthesizer
    htsCommands=`$hhedProg -Q | grep CM | awk '{print $1}'`
    # here it is used quotes for htsCommand because it can be empty ""
    if [ "$htsCommands" == "CM" ]; then
       htkPath=`dirname $hhedProg`      
       echo "HTK HHED contains HTS commands like CM "
       echo "HTK ok"
       echo
    else
       echo "HTK is installed but it seems not patched with HTS, because HHEd does not have command CM."
       echo "HTK and HDecode have to be dowloaded, patched with HTS and compiled again"
       if [ $option = "-install" ] ; then
         echo "suggested commands:"
         root=$MARY_BASE/lib/external
         echo "  mkdir -p $root/sw"
         echo "  cp HTK-3.4.tar.gz $root/sw"
         echo "  cp HDecode-3.4.tar.gz $root/sw"
         echo "  cd $root/sw"
         echo "  mkdir HTS-patch"
         echo "  cd HTS-patch"
         echo "  wget http://hts.sp.nitech.ac.jp/archives/2.1/HTS-2.1_for_HTK-3.4.tar.bz2"
         echo "  tar -jxvf HTS-2.1_for_HTK-3.4.tar.bz2"
         echo "  cd .."
         echo "  tar -zxf HTK-3.4.tar.gz"
         echo "  tar -zxf HDecode-3.4.tar.gz"
         echo "  cd htk"
         echo "  cp $root/sw/HTS-patch/HTS-2.1_for_HTK-3.4.patch ."
         echo "  patch -p1 -d . < HTS-2.1_for_HTK-3.4.patch"     
         echo "  ./configure --prefix=$root/ MAXSTRLEN=2048"
         echo "  make"
         echo "  make install"
         echo "The previous commands will be executed, it assumes that the files:"
         echo "  HTK-3.4.tar.gz"
         echo "  HDecode-3.4.tar.gz "
         echo "are in the current directory. continue (y/n)?"
         read choice
         if [ $choice = "y" ] ; then
           if [ -f HTK-3.4.tar.gz ] && [ -f HDecode-3.4.tar.gz ] ; then 
             echo "Installing HTK..."
             echo "sources will be compiled in: $root/sw"
             echo "binaries will be installed in $root/bin"
             echo
             mkdir -p $root/sw
             cp HTK-3.4.tar.gz $root/sw
             cp HDecode-3.4.tar.gz $root/sw
             cd $root/sw
             mkdir -p HTS-patch
             cd HTS-patch
             wget http://hts.sp.nitech.ac.jp/archives/2.1/HTS-2.1_for_HTK-3.4.tar.bz2
             tar -jxvf HTS-2.1_for_HTK-3.4.tar.bz2
             cd ..
             tar -zxf HTK-3.4.tar.gz
             tar -zxf HDecode-3.4.tar.gz
             cd htk
             cp $root/sw/HTS-patch/HTS-2.1_for_HTK-3.4.patch .
             echo "applying HTS patch"
             patch -p1 -d . < HTS-2.1_for_HTK-3.4.patch
             ./configure --prefix=$root MAXSTRLEN=2048
             make
             make install
             # And compile HDecode
             make hdecode
             make install-hdecode
             htkPath=$root/bin
             echo
             echo "HTK (htk and hdecode) successfully installed in: $root/bin"
             echo
          else
            echo "file: HTK-3.4.tar.gz and/or HDecode-3.4.tar.gz not found"
            echo "download or copy HTK-3.4.tar.gz and HDecode-3.4.tar.gz in the current directory"
            echo "HTK 3.4 and HDecode-3.4.tar.gz can be downloaded from: http://htk.eng.cam.ac.uk/download.shtml "
            echo 
          fi
      else
        echo "HTK patched with HTS is not installed"
        echo
      fi
    else
      echo "HTK patched with HTS is not installed"
      echo
    fi
  fi
else    
    echo "HTK 3.4 and HDecode do not exist"
    echo "HTK 3.4 and HDecode-3.4.tar.gz can be downloaded from: http://htk.eng.cam.ac.uk/download.shtml "
    echo "once HTK has been downloaded, apply the HTS patch, compile and install:"
    if [ $option = "-install" ] ; then
      echo "suggested commands:"
      root=$MARY_BASE/lib/external
      echo "  mkdir -p $root/sw"
      echo "  cp HTK-3.4.tar.gz $root/sw"
      echo "  cp HDecode-3.4.tar.gz $root/sw"
      echo "  cd $root/sw"
      echo "  mkdir HTS-patch"
      echo "  cd HTS-patch"
      echo "  wget http://hts.sp.nitech.ac.jp/archives/2.1/HTS-2.1_for_HTK-3.4.tar.bz2"
      echo "  tar -jxvf HTS-2.1_for_HTK-3.4.tar.bz2"
      echo "  cd .."
      echo "  tar -zxf HTK-3.4.tar.gz"
      echo "  tar -zxf HDecode-3.4.tar.gz"
      echo "  cd htk"
      echo "  cp $root/sw/HTS-patch/HTS-2.1_for_HTK-3.4.patch ."
      echo "  patch -p1 -d . < HTS-2.1_for_HTK-3.4.patch"     
      echo "  ./configure --prefix=$root/ MAXSTRLEN=2048"
      echo "  make"
      echo "  make install"
      echo "The previous commands will be executed, it assumes that the files:"
      echo "  HTK-3.4.tar.gz"
      echo "  HDecode-3.4.tar.gz "
      echo "are in the current directory. continue (y/n)?"
      read choice
      if [ $choice = "y" ] ; then
        if [ -f HTK-3.4.tar.gz ] && [ -f HDecode-3.4.tar.gz ] ; then 
          echo "Installing HTK..."
          echo "sources will be compiled in: $root/sw"
          echo "binaries will be installed in $root/bin"
          echo
          mkdir -p $root/sw
          cp HTK-3.4.tar.gz $root/sw
          cp HDecode-3.4.tar.gz $root/sw
          cd $root/sw
          mkdir -p HTS-patch
          cd HTS-patch
          wget http://hts.sp.nitech.ac.jp/archives/2.1/HTS-2.1_for_HTK-3.4.tar.bz2
          tar -jxvf HTS-2.1_for_HTK-3.4.tar.bz2
          cd ..
          tar -zxf HTK-3.4.tar.gz
          tar -zxf HDecode-3.4.tar.gz
          cd htk
          cp $root/sw/HTS-patch/HTS-2.1_for_HTK-3.4.patch .
          echo "applying HTS patch"
          patch -p1 -d . < HTS-2.1_for_HTK-3.4.patch
          ./configure --prefix=$root MAXSTRLEN=2048
          make
          make install
          # And compile HDecode
          make hdecode
          make install-hdecode
          htkPath=$root/bin
          echo
          echo "HTK (htk and hdecode) successfully installed in: $root/bin"
          echo
       else
          echo "file: HTK-3.4.tar.gz and/or HDecode-3.4.tar.gz not found"
          echo "download or copy HTK-3.4.tar.gz in the current directory"
          echo "HTK 3.4 can be downloaded from: http://htk.eng.cam.ac.uk/download.shtml "
          echo
          exit 
       fi 
    else
       echo "HTK is not installed"
       echo
    fi
   else
       echo "HTK is not installed"
       echo
    fi
fi


################# hts_engine
if which hts_engine > /dev/null; then
    echo "hts_engine exists"
    hts_engineProg=`which hts_engine`
    # CHECK: here it is missing to check the version!!!
    hts_enginePath=`dirname $hts_engineProg`
    echo "hts_engine: $hts_engineProg" 
    echo "ok"
    echo
else
    echo "hts_engine does not exist"
    echo "it can be download from: http://downloads.sourceforge.net/hts-engine/hts_engine_API-1.01.tar.gz "
    if [ $option = "-install" ] ; then
      echo "suggested commands:"
      root=$MARY_BASE/lib/external
      echo "  mkdir -p $root/sw"
      echo "  cd $root/sw"
      echo "  wget http://downloads.sourceforge.net/hts-engine/hts_engine_API-1.01.tar.gz"
      echo "  tar -zxf hts_engine_API-1.01.tar.gz"
      echo "  cd hts_engine_API-1.01"
      echo "  ./configure --prefix=$root"
      echo "  make"
      echo "  make install"
      echo "The previous commands will be executed. continue (y/n)?"
      read choice
      if [ $choice = "y" ] ; then
        echo "Installing hts_engine..."
        echo "sources will be downloaded and compiled in: $root/sw"
        echo "binaries will be installed in $root/bin"
        mkdir -p $root/sw
        cd $root/sw
        wget http://downloads.sourceforge.net/hts-engine/hts_engine_API-1.01.tar.gz
        tar -zxf hts_engine_API-1.01.tar.gz
        cd hts_engine_API-1.01
        ./configure --prefix=$root
        make
        make install
        hts_enginePath=$root/bin
        echo
        echo "hts_engine successfully installed in: $root/bin"
        echo
      else
        echo "hts_engine not installed"
        echo
      fi
    else
      echo "hts_engine not installed"
      echo
    fi
fi


################# SPTK
if which mgcep > /dev/null; then
    echo "SPTK mgcep exists"
    mgcepProg=`which mgcep`
    echo "SPTK mgcep: $mgcepProg" 
    #check SPTK version
    # we need SPTK 3.2 which support gmm (check if gmm exist)
    if which gmm > /dev/null; then
      sptkPath=`dirname $mgcepProg`
      echo "SPTK gmm exist, SPTK version >= 3.2" 
      echo "ok"
      echo
    else
      echo "SPTK gmm does not exist, SPTK version < 3.2" 
      echo "SPTK installed but probably an older version, please install SPTK 3.2"
      echo "it can be download from: http://downloads.sourceforge.net/sp-tk/SPTK-3.2.tar.gz "
      if [ $option = "-install" ] ; then
        echo "suggested commands:"
        root=$MARY_BASE/lib/external
        echo "  mkdir -p $root/sw"
        echo "  cd $root/sw"
        echo "  wget http://downloads.sourceforge.net/sp-tk/SPTK-3.2.tar.gz"
        echo "  tar -zxvf SPTK-3.2.tar.gz"
        echo "  cd SPTK-3.2"
        echo "  ./configure --prefix=$root"
        echo "  make"
        echo "  make install"
        echo "The previous commands will be executed. continue (y/n)?"
        read choice
        if [ $choice = "y" ] ; then
          mkdir -p $root/sw
          cd $root/sw
          wget http://downloads.sourceforge.net/sp-tk/SPTK-3.2.tar.gz
          tar -zxvf SPTK-3.2.tar.gz
          cd SPTK-3.2
          ./configure --prefix=$root
          make
          make install
          sptkPath=$root/bin
          echo
          echo "SPTK successfully installed in: $root/bin"
          echo
        else
          echo "SPTK not installed"  
        fi
      else
       echo "SPTK not installed"      
      fi
    fi
else
    echo "SPTK-3.2 does not exist" 
    echo "it can be download from: http://downloads.sourceforge.net/sp-tk/SPTK-3.2.tar.gz "
    if [ $option = "-install" ] ; then
      echo "suggested commands:"
      root=$MARY_BASE/lib/external
      echo "  mkdir -p $root/sw"
      echo "  cd $root/sw"
      echo "  wget http://downloads.sourceforge.net/sp-tk/SPTK-3.2.tar.gz"
      echo "  tar -zxvf SPTK-3.2.tar.gz"
      echo "  cd SPTK-3.2"
      echo "  ./configure --prefix=$root"
      echo "  make"
      echo "  make install"
      echo "The previous commands will be executed. continue (y/n)?"
      read choice
      if [ $choice = "y" ] ; then
        mkdir -p $root/sw
        cd $root/sw
        wget http://downloads.sourceforge.net/sp-tk/SPTK-3.2.tar.gz
        tar -zxvf SPTK-3.2.tar.gz
        cd SPTK-3.2
        ./configure --prefix=$root
        make
        make install
        sptkPath=$root/bin
        echo
        echo "SPTK successfully installed in: $root/bin"
        echo
      else
        echo "SPTK not installed"  
      fi
    else
     echo "SPTK not installed"      
    fi
fi


################# ehmm from Festival
if which ehmm > /dev/null; then
    echo "festvox ehmm exists"
    ehmmProg=`which ehmm`
    ehmmPath=`dirname $ehmmProg`
    echo "festvox ehmm: $ehmmProg" 
    echo "ehmm exist"
    echo "ok"
else
    echo "ehmm not found"
    echo "so probably festvox is not installed or provide a path for that,"
    echo "normally it can be found in your Festival directory:"
    echo "   ../Festival/festvox/src/ehmm/bin "
    echo "it can be download from: http://festvox.org/festvox-2.1/festvox-2.1-release.tar.gz "
    if [ $option = "-install" ] ; then
      echo "suggested commands:"
      root=$MARY_BASE/lib/external
      echo "  mkdir -p $root/sw"
      echo "  cd $root/sw"
      echo "  The svn version compiles with gcc 4.3"
      echo "  svn checkout http://svn.berlios.de/svnroot/repos/festlang/trunk/speech_tools"
      echo "  wget http://festvox.org/festvox-2.1/festvox-2.1-release.tar.gz"
      echo "  cd speech_tools"
      echo "  ./configure"
      echo "  make"
      echo "  cd .."
      echo "  tar -zxf festvox-2.1-release.tar.gz"
      echo "  cd festvox"
      echo "  We need the following to being able to compile in gcc 4.3"
      echo "  echo \"#include<string.h>\" > tmp"
      echo "  cat tmp src/ehmm/src/ehmm.cc > src/ehmm/src/ehmm.cc.tmp"
      echo "  cat tmp src/ehmm/src/edec.cc > src/ehmm/src/edec.cc.tmp"
      echo "  mv src/ehmm/src/ehmm.cc.tmp src/ehmm/src/ehmm.cc"
      echo "  mv src/ehmm/src/edec.cc.tmp src/ehmm/src/edec.cc"
      echo "  rm tmp"
      echo "  ./configure"
      echo "  make"
      echo "The previous commands will be executed. continue (y/n)?"
      read choice
      if [ $choice = "y" ] ; then
        root=$MARY_BASE/lib/external
        mkdir -p $root/sw
        cd $root/sw
        svn checkout http://svn.berlios.de/svnroot/repos/festlang/trunk/speech_tools
        wget http://festvox.org/festvox-2.1/festvox-2.1-release.tar.gz
        cd speech_tools
        ./configure
        make
        cd ..
        tar -zxf festvox-2.1-release.tar.gz
        cd festvox
        echo "#include<string.h>" > tmp
        cat tmp src/ehmm/src/ehmm.cc > src/ehmm/src/ehmm.cc.tmp
        cat tmp src/ehmm/src/edec.cc > src/ehmm/src/edec.cc.tmp
        mv src/ehmm/src/ehmm.cc.tmp src/ehmm/src/ehmm.cc
        mv src/ehmm/src/edec.cc.tmp src/ehmm/src/edec.cc
        rm tmp
        ./configure
        make
        cp src/ehmm/bin/* $root/bin
        ehmmPath=$root/bin
        echo
        echo "ehmm successfully installed in: $root/bin"
        echo
      else
        echo "ehmm not installed"
      fi
    else
     echo "ehmm not installed" 
    fi
fi



############ paths
out_file=$MARY_BASE/lib/external/externalBinaries.config




echo "# Paths for external programs:" > $out_file
echo ""
echo "________________________________________________________________"
echo "Programs status (detailed information above):"
echo "The following paths should be in the PATH variable"

if [ "$awkPath" != "" ] ; then 
  echo "external.awkPath $awkPath" >> $out_file
  echo "  awk: $awkPath" 
else
  echo "  awk: missing path"
fi
if [ "$perlPath" != "" ] ; then 
  echo "external.perlPath $perlPath" >> $out_file
  echo "  perl: $perlPath"
else
  echo "  perl: missing path"
fi
if [ "$bcPath"  != "" ] ; then 
  echo "external.bcPath $bcPath" >> $out_file
  echo "  bc: $bcPath"
else
  echo "  bc: missing path"
fi

echo "The following paths are used when running HMMVoiceConfigure"
if [ "$tclshPath" != "" ] ; then 
  echo "external.tclPath $tclshPath" >> $out_file
  echo "  tclsh: $tclshPath"
else
  echo "  tclsh: missing path"
fi
if [ "$soxPath" != "" ] ; then 
  echo "external.soxPath $soxPath" >> $out_file
  echo "  sox: $soxPath"
else
  echo "  sox: missing path"
fi
if [ "$htkPath" != "" ] ; then 
  echo "external.htsPath $htkPath" >> $out_file
  echo "  hts/htk: $htkPath"
else
  echo "  hts/htk: misising path"
fi
if [ "$hts_enginePath" != "" ] ; then 
  echo "external.htsEnginePath $hts_enginePath" >> $out_file
  echo "  hts_engine: $hts_enginePath"
else
  echo "  hts_engine: missing path"
fi
if [ "$sptkPath" != "" ] ; then 
  echo "external.sptkPath $sptkPath" >> $out_file
  echo "  sptk: $sptkPath"
else
  echo "  sptk: missing path"
fi

echo "This path is used when running the EHMMlabeler"  
if [ "$ehmmPath" != "" ] ; then 
  echo "external.ehmmPath $ehmmPath" >> $out_file
  echo "  ehmm: $ehmmPath"
else
  echo "  ehmm: missing path"
fi

echo
echo "List of paths in: $out_file"
echo "" 

# Disable exit trap
trap - EXIT
exit 1