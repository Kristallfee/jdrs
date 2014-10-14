
echo " "
echo "Set the environemnt variables for the ToPix4 JDRS for IKP556"
echo "------------------------------------------------------------"
echo " "

# JDRS
echo "Set JDRS path"
echo "------------"
export JDRSPATH="/home/ikp1/esch/chip_readout/git_repository/jdrs"

# FAIRROOTBUILDPATH
echo "Set FAIRROOTBUILDPATH"
echo "----------------"
export FAIRROOTBUILDPATH="/private/fairroot/build_Branch_Alice_HLT_Ex"

# FairRoot
echo "Set FairRoot"
echo "------------"
source $FAIRROOTBUILDPATH/config.sh

# FAIRROOTPATH
echo "Set FAIRROOTPATH"
echo "----------------"
export FAIRROOTPATH="/private/fairroot/install_Branch_Alice_HLT_Ex"

# qt 5.3.1
echo "Set QT"
echo "------"
export PATH="/private/esch/qt_5.3.1/5.3/gcc_64/bin:$PATH"
