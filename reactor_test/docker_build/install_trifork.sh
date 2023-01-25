#!/bin/sh
# set -x
VERSION=4.1.40
REL_BASE_DIR=`dirname $0`
REL_BASE_DIR="$HOME/Infopark-CMS-Fiona-7.0.2-Linux/trifork-4.1.40"
BASE_DIR=`cd $REL_BASE_DIR && pwd || echo "Unable to cd into $REL_BASE_DIR"; exit 1`
BASE_DIR=`pwd`

INSTALL_DIR=$HOME/trifork-$VERSION
INSTALL_SAMPLES=no
INSTALL_SAMPLES_DOMAIN=no
INSTALL_DOC=no
INSTALL_JDK=yes

DEFAULT_DOMAIN_FILE=default-domain.tar
DOC_FILE=documentation.tar
SAMPLES_DOMAIN_FILE=samples-domain.tar
SAMPLES_FILE=samples.tar
SERVER_FILE=server.tar
JDK_FILE=jdk.tar

JDK_VERSION=1.4.0
JDK_HOME=INSTALL_DIR/jdk-JDK_VERSION

#echo
#echo Welcome to the Trifork T4 Setup Wizard
#echo
#echo This will install Trifork T4 $VERSION on your computer
#echo
#
#echo "Press <enter> to continue: "|tr -d '\012'
#read reply leftover
#
#
#
#more <<"EOF"
#-----------------------------------------------------
#Trifork Application Server Software and Documentation
#
#Evaluation License Agreement
#-----------------------------------------------------
#
#PLEASE READ THE FOLLOWING EVALUATION LICENSE AGREEMENT ("AGREEMENT")
#CAREFULLY BEFORE DOWNLOADING OR USING THE SOFTWARE AND THE
#DOCUMENTATION AND INDICATE YOUR ACCEPTANCE BY CLICKING THE ACCEPTANCE
#BOX BELOW.  THE LICENSE AGREEMENT CONTAINS LIMITATION AND EXCLUSION OF
#LIABILITY. IF YOU DO NOT ACCEPT THE TERMS AND CONDITIONS OF THIS
#AGREEMENT YOU SHOULD NOT USE THE SOFTWARE OR DOCUMENTATION.
#
#This Evaluation License agreement ("Agreement") is a license granted
#by Trifork Technologies, Margrethepladsen 3, DK-8000 �rhus C
#("TRIFORK") to you ("You") for the use of the Trifork Application
#Server in binary, object code form (the "Software") and the related
#documentation ("Documentation") in accordance with the following terms
#and conditions.
#
#1. OWNERSHIP AND PROPRIETARY NOTICES
#The Software (including any header files and demonstration code that
#may be included) and all related materials and associated copyrights
#and other intellectual property rights, are the property of TRIFORK or
#its licensors. You acquire no title, right or interest in the Software
#or related materials other than the license granted herein by TRIFORK.
#You shall not remove any tradename, trademark, copyright notice or
#other proprietary notice from the Software or related materials and
#You may not reproduce any portion of the Software or related
#materials, except as permitted by this Agreement.
#
#2. LICENSE
#(i) TRIFORK hereby grants to You a nonexclusive, nontransferable,
#internal, limited license to evaluate the Software and related
#materials at Your premises only and for the term of this Agreement
#only. The Software and related materials are provided for evaluation
#purposes only and no commercial product development work of any kind
#is authorized under this Agreement.
#(ii) The source code of the Software (other than included header files
#and demonstration code) and design documentation are confidential and
#proprietary information and trade secrets of TRIFORK, its suppliers
#and/or licensors, are never considered part of the Software, and are
#neither delivered to You nor under any circumstances licensed to You
#hereunder.
#
#3. COPY RESTRICTIONS AND OTHER RESTRICTIONS
#(i) You may make a reasonable number of copies of the Software in
#machine-readable, object code form, as permitted by applicable law,
#solely for backup or archival purposes, provided that such copies of
#the Software shall include all applicable copyright, trademark and
#other proprietary notices of TRIFORK.
#(ii) You will not display or disclose the Product to third parties,
#rent, lease, loan, sublicense, modify, adapt, translate, reverse
#engineer, disassemble or decompile the Product or any portion
#thereof. You may make a written request to TRIFORK for such
#information. You shall promptly report to TRIFORK any actual or
#suspected violation of this section and shall take further steps as
#may reasonably be requested by TRIFORK to prevent or remedy any such
#violation.
#
#4. U.S. GOVERNMENT END-USERS
#The Software and the related materials are considered "commercial
#items" as that term is defined in 48 C.F.R. 2.101 consisting of
#"commercial computer software" and "commercial computer software
#documentation" as such terms are used in 48 C.F.R. 12.212. Consistent
#with 48 C.F.R. 12.212 and 48 C.F.R. 227.7202-1, 227.7202-3 and
#227.7202-4, if the licensee hereunder is the U.S. Government or any
#agency or department thereof, the Software and the related Materials
#are licensed hereunder (i) only as a commercial item, and (ii) with
#only those rights as are granted to all other end users pursuant to
#the terms and conditions of this Agreement.
#
#5. SUPPORT
#Support services for the Software are available from TRIFORK for the
#term of this Agreement through TRIFORK�s web page www.trifork.com and
#on the terms and conditions as set out there.
#
#6. DURATION
#This Agreement is effective from the date this Software is installed
#by You and shall remain in force for thirty (30) days.
#
#7. EXCLUSION AND LIMITATION OF LIABILITY
#TRIFORK SPECIFICALLY DISCLAIMS ANY WARRANTY THAT THE FUNCTIONS
#CONTAINED IN THE SOFTWARE OR THE RESULTS OF USE WILL MEET YOUR
#REQUIREMENTS, OR THAT THE OPERATION OF THE SOFTWARE WILL BE
#UNINTERRUPTED OR ERROR FREE. EXCEPT AS EXPRESSLY SET FORTH ABOVE, THE
#PRODUCT IS PROVIDED TO YOU "AS IS" WITHOUT WARRANTY OF ANY KIND,
#EITHER EXPRESS OR IMPLIED, STATUTORY OR OTHERWISE, INCLUDING, BUT NOT
#LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
#PARTICULAR PURPOSE AND NON-INFRINGEMENT. THE ENTIRE RISK AS TO THE
#SUITABILITY, QUALITY AND PERFORMANCE OF THE PRODUCT IS WITH YOU AND
#NOT WITH TRIFORK. SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OF
#IMPLIED WARRANTIES, SO SUCH EXCLUSION MAY NOT APPLY TO YOU.
#
#THE SOFTWARE AND DOCUMENTATION IS PROVIDED GRATUITOUSLEY FOR
#EVALUATION PURPOSES AND THEREFORE TRIFORK, ITS SUPPLIERS OR LICENSORS
#SHALL IN NO EVENT BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#CONSEQUENTIAL, SPECIAL, PUNITIVE OR EXEMPLARY DAMAGES (INCLUDING, BUT
#NOT LIMITED TO, DAMAGES FOR LOSS OF BUSINESS PROFITS, BUSINESS
#INTERRUPTION, LOSS OF BUSINESS INFORMATION, DATA, GOODWILL OR OTHER
#PECUNIARY LOSS) ARISING OUT OF THE USE OR INABILITY TO USE THE
#SOFTWARE, EVEN IF FORSEEABLE OR IF TRIFORK HAS BEEN ADVISED OF THE
#POSSIBILITY OF SUCH DAMAGES. IN NO EVENT SHALL TRIFORK BE RESPONSIBLE
#OR HELD LIABLE FOR ANY DAMAGES RESULTING FROM PHYSICAL DAMAGE TO
#TANGIBLE PROPERTY OR DEATH OR INJURY OF ANY PERSON WHETHER ARISING
#FROM TRIFORK'S NEGLIGENCE OR OTHERWISE. BECAUSE SOME JURISDICTIONS DO
#NOT ALLOW CERTAIN OF THE ABOVE EXCLUSIONS OR LIMITATIONS OF LIABILITY,
#THE ABOVE LIMITATIONS MAY NOT APPLY TO YOU.
#
#8. AMENDMENT; WAIVER
#No modification or waiver of any provision of this Agreement shall be
#binding on either party unless specifically agreed upon in a writing
#signed by both parties. Any failure or delay by TRIFORK to exercise or
#enforce any of the rights or remedies granted hereunder will not
#operate as a waiver thereof. No waiver by TRIFORK of any breach of
#this Agreement will operate as a waiver of any other or subsequent
#breach.
#
#9. SEVERABILITY
#If any provision of this Agreement is found invalid or unenforceable,
#that provision will be reformed, construed and enforced to the maximum
#extent permissible, and the other provisions of this Agreement will
#remain in full force and effect.
#
#10. LAW AND JURISDICTION
#This Agreement shall be governed by and construed in accordance with
#the laws of Denmark, excluding Danish conflicts of law rules, and the
#parties hereby irrevocably submit to the venue and jurisdiction of the
#courts of Denmark.
#
#11. EXPORT ADMINISTRATION ACT.
#You will not import, export or re-export the Software to or from any
#country in contravention of any applicable import or export
#laws. TRIFORK will provide reasonable product information to assist
#You in discharging its obligations under this section.
#
#12. ENTIRE AGREEMENT
#You have read this Agreement and agree to be bound by its terms. You
#further agree that, this Agreement constitutes the complete and entire
#agreement of the parties and supersedes all previous communications
#between them relating to the subject matter hereof. No representations
#or statements of any kind made by either party relating to the subject
#matter hereo, which are not expressly stated herein, shall be binding
#on such party.
#EOF
#agreed=
#while [ x$agreed = x ]; do
#  echo
#  echo "Do you agree to the above license terms? [yes or no]: "|tr -d '\012'
#  read reply leftover
#  case $reply in
#      y* | Y*)
#          agreed=1;;
#      n* | N*)
#  echo "If you do not agree to the license you may not install this sofware";
#  exit 1;;
#  esac
#done


target=0
while [ "$target" -eq 0 ]
do
  #echo
  #echo
  #echo
  #echo Select Destination Directory:
  #echo -----------------------------
  #echo "Where should the Trifork Enterprise Application Server be installed [ $INSTALL_DIR ]:"|tr -d '\012'
  #read install_dir
  #if [ ! "$install_dir" ]; then
  #  install_dir=$INSTALL_DIR
  #fi
  install_dir=$INSTALL_DIR
  if [ ! -d "$install_dir" ]; then
    newDir=1;
  fi
  mkdir -p $install_dir
  if [ $? -ne 0 ]; then
    newDir=0;
    echo
    echo "Access to $install_dir denied."
    echo "Please choose another directory."
  else
    save_dir_temp=`pwd`
    INSTALL_DIR=$install_dir
    target=1
  fi
done

#echo
#echo
#echo
#echo Select Components:
#echo ------------------
#agreed=
#while [ x$agreed = x ]; do
#  echo "Install Sample Enterprise Applications [yes or no]: "|tr -d '\012'
#  read reply leftover
#  case $reply in
#      y* | Y*)
#          INSTALL_SAMPLES=yes;
#          agreed=1;;
#      n* | N*)
#          INSTALL_SAMPLES=no;
#          agreed=1;;
#  esac
#done
#
#agreed=
#while [ x$agreed = x ]; do
#  echo "Install a domain with predeployed sample applications [yes or no]: "|tr -d '\012'
#  read reply leftover
#  case $reply in
#      y* | Y*)
#          INSTALL_SAMPLES_DOMAIN=yes;
#          agreed=1;;
#      n* | N*)
#          INSTALL_SAMPLES_DOMAIN=no;
#          agreed=1;;
#  esac
#done
#
#agreed=
#while [ x$agreed = x ]; do
#  echo "Install user documentation [yes or no]: "|tr -d '\012'
#  read reply leftover
#  case $reply in
#      y* | Y*)
#          INSTALL_DOC=yes;
#          agreed=1;;
#      n* | N*)
#          INSTALL_DOC=no;
#          agreed=1;;
#  esac
#done
#
#echo
#echo
#echo
echo Starting the installation...

echo Installing server files...

untar() {
    (cd $2; tar xf $1)
}

untar $BASE_DIR/data/$SERVER_FILE $INSTALL_DIR
chmod 775 $INSTALL_DIR/server/bin/*
chmod 775 $INSTALL_DIR/server/ant/bin/*

echo Installing default domain...
mkdir $INSTALL_DIR/domains
untar $BASE_DIR/data/$DEFAULT_DOMAIN_FILE $INSTALL_DIR/domains
rm $INSTALL_DIR/domains/default/bin/*
$BASE_DIR/data/installer/createSetDomainEnv.sh $INSTALL_DIR/domains/default/bin/setDomainEnv.sh $INSTALL_DIR/domains/default $INSTALL_DIR/server default
$BASE_DIR/data/installer/createStartDevelServer.sh $INSTALL_DIR/domains/default/bin/startDevelServer.sh $INSTALL_DIR/domains/default
$BASE_DIR/data/installer/createStartDevelServerXXX.sh $INSTALL_DIR/domains/default/bin/startDevelServer-default.sh $INSTALL_DIR/domains/default default
$BASE_DIR/data/installer/createStartProductionServer.sh $INSTALL_DIR/domains/default/bin/startProductionServer.sh $INSTALL_DIR/domains/default
$BASE_DIR/data/installer/createStartProductionServerXXX.sh $INSTALL_DIR/domains/default/bin/startProductionServer-default.sh $INSTALL_DIR/domains/default default
$BASE_DIR/data/installer/createTrifork.sh $INSTALL_DIR/domains/default/bin/trifork $INSTALL_DIR/domains/default
chmod 775 $INSTALL_DIR/domains/default/bin/*

if [ "$INSTALL_SAMPLES" = "yes" ]
then
  echo Installing sample applications...
  untar $BASE_DIR/data/$SAMPLES_FILE $INSTALL_DIR
fi

if [ "$INSTALL_SAMPLES_DOMAIN" = "yes" ]
then
  echo Installing samples domain...
  untar $BASE_DIR/data/$SAMPLES_DOMAIN_FILE $INSTALL_DIR/domains
  rm $INSTALL_DIR/domains/samples/bin/*.cmd
  $BASE_DIR/data/installer/createSetDomainEnv.sh $INSTALL_DIR/domains/samples/bin/setDomainEnv.sh $INSTALL_DIR/domains/samples $INSTALL_DIR/server samples
  $BASE_DIR/data/installer/createStartDevelServer.sh $INSTALL_DIR/domains/samples/bin/startDevelServer.sh $INSTALL_DIR/domains/samples
  $BASE_DIR/data/installer/createStartDevelServerXXX.sh $INSTALL_DIR/domains/samples/bin/startDevelServer-samples.sh $INSTALL_DIR/domains/samples samples
  $BASE_DIR/data/installer/createStartProductionServer.sh $INSTALL_DIR/domains/samples/bin/startProductionServer.sh $INSTALL_DIR/domains/samples
  $BASE_DIR/data/installer/createStartProductionServerXXX.sh $INSTALL_DIR/domains/samples/bin/startProductionServer-samples.sh $INSTALL_DIR/domains/samples samples
  $BASE_DIR/data/installer/createTrifork.sh $INSTALL_DIR/domains/samples/bin/trifork $INSTALL_DIR/domains/samples
  chmod 775 $INSTALL_DIR/domains/samples/bin/*

fi

if [ "$INSTALL_DOC" = "yes" ]
then
  echo Installing user documentation...
  untar $BASE_DIR/data/$DOC_FILE $INSTALL_DIR
fi

echo Installation completed...

echo
echo
echo To start the server, make sure the 'java' command from JDK-1.4.x or higher is in your PATH, then go to the $INSTALL_DIR/domains/default/bin directory and type
echo ./startDevelServer-default.sh

if [ "$INSTALL_DOC" = "yes" ]
then
  echo
  echo See the Getting Started Guide of the user documentation for a quick guide of how to use the server
fi
