#include "mainwindow.h"
#include "mrftools.h"
#include "qmrftools.h"
#include "ui_mainwindow.h"
#include <QFile>
#include <QTextStream>
#include "mrfdata_8b.h"
#include "FairMQTransportFactoryZMQ.h"

using mrftools::getIntBit;
using mrftools::setIntBit;
using mrftools::shiftBy;
using mrftools::getIteratorItemCount;

using qmrftools::assignCommandValues;
using qmrftools::assignGlobalValues;
using qmrftools::assignDACValues;
using qmrftools::assignDACActivated;
using qmrftools::fillItemComboBox;
using qmrftools::clearItemTable;
using qmrftools::clearItemTable2d;
using qmrftools::fillItemTable;
using qmrftools::assignItemValues;
using qmrftools::fillItemComboBox;


MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow),appauthor("S.Esch"), appname("ToPix4 Readout Controll"),_ltc2604()
{
    ui->setupUi(this);
    on_pushButton_ltc2604clear_clicked();
    on_pushButton_ltc2604clearcommand_clicked();
    on_pushButton_topix4clearcommand_clicked();
    on_pushButton_topix4clearread_clicked();
    _end_readout = false;
    on_toolButton_refreshOwnIP_clicked();
    on_toolButton_refreshOwnIP_1_clicked();

    on_pushButton_p3allclear_clicked();
    p3testpulsclear();
    ui->tableWidget_p3masktest->setRowCount(20);
    ui->tableWidget_p3masktest->setColumnCount(32);
    on_pushButton_p3maskclear_clicked();
    p3testpulsclear();
    _errorstrcon = new TMrfStrError();
    _errorstrcon->setDelimiter("");

}

MainWindow::~MainWindow()
{
   // fairmqreadout.ChangeState(ToPix4_FairMQ_Reaout::STOP);
    fairmqreadout.ChangeState(ToPix4_FairMQ_Readout::END);
    delete ui;
}

void MainWindow::on_pushButton_injectchargeinternalunsync_clicked()
{
    injectChargeInternalUnsync();
}

void MainWindow::injetChargeInternalSync(int delay, int wait)
{
    std::cout << "not yet implemented " << delay<< wait<<  std::endl;
}



void MainWindow::injectChargeInternalUnsync()
{
//    _topix4command.setOperationCode(topix4_command::);
//    _topixflags.setLocalItemValue("CounterReset", 1);
//    _topixflags.assemble();
//    _topixcrtl.configTopixSlowReg(_topixflags);
//    _topixflags.setLocalItemValue("CounterReset", 0);
//    _topixflags.assemble();
//    _topixcrtl.configTopixSlowReg(_topixflags);

    _topix4control.writeOr(0x480,2);
    usleep(5);
    _topix4control.writeXor(0x480,2);

//    _topix.setLocalItemValue("TestPin", 1);
//    _topixflags.assemble();
//    _topixcrtl.configTopixSlowReg(_topixflags);
//    usleep(5);
//    _topixflags.setLocalItemValue("TestPin", 0);
//    _topixflags.assemble();
//    _topixcrtl.configTopixSlowReg(_topixflags);
}


//#############################

void MainWindow::on_pushButton_start_fairmq_sm_clicked()
{
    fairmqreadout.ChangeState(ToPix4_FairMQ_Readout::RUN);
}

void MainWindow::on_pushButton_pause_fairmq_sm_clicked()
{
    fairmqreadout.ChangeState(ToPix4_FairMQ_Readout::PAUSE);
    QCoreApplication::processEvents();
}

void MainWindow::on_pushButton_start_fairmq_thread_clicked()
{
    DoFairMQReadout();
}

void MainWindow::on_pushButton_stop_fairmq_sm_clicked()
{
    fairmqreadout.ChangeState(ToPix4_FairMQ_Readout::STOP);
}

void MainWindow::on_pushButton_stop_fairmq_thread_clicked()
{

    fairmqreadout.ChangeState(ToPix4_FairMQ_Readout::END);
    fairmqreadout.CloseASICConnection();
}

void MainWindow::DoFairMQReadout()
{
 //   if (_topix4control.deviceIsOpen())
  //  {
  //     on_pushButton_Disconnect_UDP_clicked();
  //  }

    QStringList ownIP = ui->comboBox_ownIPAdresses_FairMQ->currentText().split(" ");
    QString connectionParameter = QString("%1,%2,%3,%4")
            .arg(ownIP[0])
            .arg(ui->spinBox_ownPort_FairMQ->value())
            .arg(ui->lineEdit_remoteIPAddress->text())
            .arg(ui->spinBox_remotePort->value());

    FairMQTransportFactory* transportFactory = new FairMQTransportFactoryZMQ();

    fairmqreadout.SetOutputWindow(ui->textEdit_Dmadata);
    fairmqreadout.SetTransport(transportFactory);
    fairmqreadout.SetProperty(ToPix4_FairMQ_Readout::Id, "100");
    fairmqreadout.SetProperty(ToPix4_FairMQ_Readout::EventSize, ui->lineEdit_fairmq_message_size->text().toInt()); //in 40 bit words
    fairmqreadout.SetProperty(ToPix4_FairMQ_Readout::NumIoThreads, 1);
    fairmqreadout.SetProperty(ToPix4_FairMQ_Readout::NumInputs, 0);
    fairmqreadout.SetProperty(ToPix4_FairMQ_Readout::NumOutputs, 1);

    fairmqreadout.ChangeState(ToPix4_FairMQ_Readout::INIT);

    fairmqreadout.SetBigCounter(ui->checkBox_bigcounter->isChecked());
    fairmqreadout.SetSaveData(ui->checkBox_savetofile->isChecked(),ui->lineEdit_savetofile_path->text().toStdString());


    fairmqreadout.SetProperty(ToPix4_FairMQ_Readout::OutputSocketType,"push" , 0);
    fairmqreadout.SetProperty(ToPix4_FairMQ_Readout::OutputSndBufSize,ui->lineEdit_fairmq_watermark->text().toInt());
    fairmqreadout.SetProperty(ToPix4_FairMQ_Readout::OutputMethod,"connect");
    fairmqreadout.SetProperty(ToPix4_FairMQ_Readout::OutputAddress,"tcp://localhost:5565");

    fairmqreadout.ChangeState(ToPix4_FairMQ_Readout::SETOUTPUT);
    fairmqreadout.ChangeState(ToPix4_FairMQ_Readout::SETINPUT);

    fairmqreadout.OpenASICConnection(connectionParameter);
}

void MainWindow::itemcolormatrix(QTableWidgetItem *item, int range)
{
    if(range ==1)
    {

        if(item->text().toUInt()==0)
        {
            item->setBackgroundColor(Qt::green);
        }
        else if(item->text().toUInt()==1)
        {
            item->setBackgroundColor(Qt::red);
        }
        else
        {
            item->setBackgroundColor(Qt::blue);
        }
    }
    else if(range == 2)
    {
        if(item->text().toUInt()==0)
        {

        }
    }
}

bool MainWindow::Error()
{
    if ( (_topix4control.getLastError() == 0))
    {
        return 0;
    }
    else
    {
        _topix4control.getLastError();
        _errorstrcon->getErrorStr(_topix4control.getLastError());

        Print(QString::fromStdString(_errorstrcon->getErrorStr(_topix4control.getLastError())));
        return 1;
    }
}

void MainWindow::Print(const QString& str)
{
    if (str != ""){
        ui->textEdit_Info->append(str);
        //statusbar->showMessage(str, 5000);
    }
}

void MainWindow::on_pushButton_ConfigFakeData_clicked()
{
    if (!_topix4control.deviceIsOpen())
    {
       on_pushButton_Connect_UDP_clicked();
    }

    _topix4control.write(0x4d4, 0x3);
    _topix4control.write(0x4d8, ui->lineEdit_fakedata_cyclesbetweenmessages->text().toInt(0,16)  );
    _topix4control.write(0x8, 0x400);
    _topix4control.write(0x4c8,0x3);
    //   _topixcrtl.write(ui->lineEdit_Registeraddress->text().toUInt(0, 16), ui->lineEdit_Registervalue->text().toUInt(0, 16));
    Error();
}

// *************************************************************************************
//tab register
// *************************************************************************************

uint MainWindow::GetAddress(QString name)
{
    uint address;
    if(name =="0x0008 Control Register")
    {
        address = 0x8;
    }
    else if (name =="0x0420 Dummy Data Register")
    {
        address = 0x420;
    }
    else if (name=="0x04C8 LED Register")
    {
        address = 0x4C8;
    }
    else if (name=="0x0494 LTC Fifo")
    {
        address = 0x494;
    }
    else if (name=="0x0488 Input Length")
    {
        address = 0x488;
    }
    else if (name=="0x0484 Input Fifo")
    {
        address = 0x484;
    }
    else if (name== "0x0424 Sdata out Fifo")
    {
        address = 0x424;
    }
    else if (name=="0x0480 Slow Control")
    {
        address = 0x480;
    }
    else
    {
        address =0;
    }
    return address;
}

void MainWindow::on_pushButton_Writeregister_clicked()
{
    _topix4control.write(GetAddress(ui->comboBox_Registeraddress->currentText()), ui->lineEdit_Registervalue->text().toUInt(0, 16) );
    //   _topixcrtl.write(ui->lineEdit_Registeraddress->text().toUInt(0, 16), ui->lineEdit_Registervalue->text().toUInt(0, 16));
    Error();
}

void MainWindow::on_pushButton_Readregister_clicked()
{
    ui->lineEdit_Registervalue->setText(QString::number(_topix4control.read(GetAddress(ui->comboBox_Registeraddress->currentText())), 16));
    Error();
}

void MainWindow::on_pushButton_Writeregister_2_clicked()
{
    _topix4control.write(ui->lineEdit_Registeraddress_2->text().toUInt(0, 16), ui->lineEdit_Registervalue_2->text().toUInt(0, 16));
    Error();
}

void MainWindow::on_pushButton_Readregister_2_clicked()
{
    ui->lineEdit_Registervalue_2->setText(QString::number(_topix4control.read(ui->lineEdit_Registeraddress_2->text().toUInt(0, 16)), 16));
    Error();
}

void MainWindow::on_pushButton_Readdmadata_clicked()
{
    TMrfData_8b tempdaten;

    _topix4control.readOutputBuffer(tempdaten,ui->spinBox_numberoddmapackages->value()*5);
    Error();

    ui->textEdit_Dmadata->append("Readback: " + QString::number(tempdaten.getNumWords()/5) + " words.");
    for(u_int i=0; i< tempdaten.getNumWords();i+=5)
    {
        ui->textEdit_Dmadata->append(QString::number((u_int16_t)tempdaten.getWord(i),16)+" "+ QString::number((u_int16_t)tempdaten.getWord(i+1),16)+" "+QString::number((u_int16_t)tempdaten.getWord(i+2),16)+" "+QString::number((u_int16_t)tempdaten.getWord(i+3),16)+" "+QString::number((u_int16_t)tempdaten.getWord(i+4),16));
    }
}

void MainWindow::on_pushButton_Configmmcm_clicked()
{

    double frequency= _topix4control.configMMCM(ui->lineEdit_Mmcmfrequency->text().toDouble());   // frequency in MHz
    //_topixtest.setTimeStep(1000/frequency);   // timestep in ns

    ui->lineEdit_Mmcmsetfrequency->setText(QString::number(frequency, 'f'));
    /*
    mrf_mmcm *blubb = new mrf_mmcm();
    double frequency = blubb->calc_fout(lineEdit_mmcm_frequency->text().toDouble());
    lineEdit_possible_frequency->setText(QString::number(frequency, 'f'));
*/
    Error();
    if(frequency==0)
    {
        ui->lineEdit_Mmcmsetfrequency->setText("No frequency found");
        return ;
    }
}

void MainWindow::on_pushButton_cleardmadata_clicked()
{
    ui->textEdit_Dmadata->clear();
}

void MainWindow::on_pushButton_fillFifo_clicked()
{
    for (int i=0; i<256; i++){
        _topix4control.write(tpx_address::dummyfiforeg,i);
    }
}

// *************************************************************************************
//tab ltc2604
// *************************************************************************************

void MainWindow::on_pushButton_ltc2604clear_clicked()
{
    clearItemTable2d(getIteratorItemCount(_ltc2604.getLTCIteratorBegin(), _ltc2604.getLTCIteratorEnd()), *ui->tableWidget_ltc2604dacs);
    clearItemTable2d(getIteratorItemCount(_ltc2604.getLTCActivatedIteratorBegin(), _ltc2604.getLTCActivatedIteratorEnd()), *ui->tableWidget_ltc2604dacactivated);
    fillItemTable(_ltc2604.getLTCIteratorBegin(), _ltc2604.getLTCIteratorEnd(), *ui->tableWidget_ltc2604dacs);
    fillItemTable(_ltc2604.getLTCActivatedIteratorBegin(), _ltc2604.getLTCActivatedIteratorEnd(), *ui->tableWidget_ltc2604dacactivated);
}

void MainWindow::on_pushButton_ltc2604cancel_clicked()
{
    fillItemTable(_ltc2604.getLTCIteratorBegin(), _ltc2604.getLTCIteratorEnd(), *ui->tableWidget_ltc2604dacs );
}

void MainWindow::on_pushButton_configureltc2604_clicked()
{
    assignDACValues(_ltc2604, *ui->tableWidget_ltc2604dacs);
    assignDACActivated(_ltc2604, *ui->tableWidget_ltc2604dacactivated);
    _topix4control.configLTC(_ltc2604);
    // Error();
}

void MainWindow::on_pushButton_ltc2604clearcommand_clicked()
{
    clearItemTable2d(getIteratorItemCount(_ltc2604.getConstTypeIteratorBegin(), _ltc2604.getConstTypeIteratorEnd()), *ui->tableWidget_ltc2604command);
    fillItemTable(_ltc2604.getConstTypeIteratorBegin(), _ltc2604.getConstTypeIteratorEnd(), *ui->tableWidget_ltc2604command);
}

void MainWindow::on_pushButton_ltc2604cancelcommand_clicked()
{
    fillItemTable(_ltc2604.getConstTypeIteratorBegin(), _ltc2604.getConstTypeIteratorEnd(), *ui->tableWidget_ltc2604command);
}

void MainWindow::on_pushButton_ltc2604sendcommand_clicked()
{
    assignItemValues(_ltc2604, *ui->tableWidget_ltc2604command);
    _topix4control.writeLTCData(_ltc2604);
}

void MainWindow::on_pushButton_ltc2604loadmodule4_clicked()
{
    _ltc2604.setDACValue("LTC1","DACA",5000);
    _ltc2604.setDACValue("LTC1","DACB",45580);
    _ltc2604.setDACValue("LTC1","DACC",40350);
    _ltc2604.setDACValue("LTC1","DACD",37600);
    _ltc2604.setDACValue("LTC2","DACC",37300);
    _ltc2604.setDACValue("LTC2","DACD",32450);

    _ltc2604.setDACActivated("LTC1","DACA",1);
    _ltc2604.setDACActivated("LTC1","DACB",1);
    _ltc2604.setDACActivated("LTC1","DACC",1);
    _ltc2604.setDACActivated("LTC1","DACD",1);
    _ltc2604.setDACActivated("LTC2","DACC",1);
    _ltc2604.setDACActivated("LTC2","DACD",1);

    on_pushButton_ltc2604clear_clicked();
}

void MainWindow::setCalLevel(int cal_level_in_DAC)
{
    _ltc2604.setDACValue("LTC1","DACA",cal_level_in_DAC);
    on_pushButton_configureltc2604_clicked();
}

// *************************************************************************************
//tab connection UDP
// *************************************************************************************


void MainWindow::on_pushButton_Connect_UDP_clicked() {
    // check for empty fields
    if ( ui->comboBox_ownIPAdresses->currentText().length() == 0 ||
         ui->spinBox_ownPort->value() == 0 ||
         ui->lineEdit_remoteIPAddress->text().length() == 0 ||
         ui->spinBox_remotePort->value() == 0 ) {
         ui->textEdit_Info->append("One of the required fields for the connection is empty, please check.");
        return;
    }

    QStringList ownIP = ui->comboBox_ownIPAdresses->currentText().split(" ");
    QString connectionParameter = QString("%1,%2,%3,%4")
            .arg(ownIP[0])
            .arg(ui->spinBox_ownPort->value())
            .arg(ui->lineEdit_remoteIPAddress->text())
            .arg(ui->spinBox_remotePort->value());

    _topix4control.openDevice( connectionParameter.toLatin1() );

    if (!Error()) {
        ui->pushButton_Connect_UDP->setEnabled(false);
        ui->pushButton_Disconnect_UDP->setEnabled(true);
        ui->textEdit_Info->append("Device successfully opened!");
    }
}

void MainWindow::on_pushButton_Disconnect_UDP_clicked() {
    _topix4control.closeDevice();
    if (!Error()) {
        ui->pushButton_Connect_UDP->setEnabled(true);
        ui->pushButton_Disconnect_UDP->setEnabled(false);
        ui->textEdit_Info->append("Device successfully closed!");
    }
}


void MainWindow::on_toolButton_refreshOwnIP_clicked() {
    _hostAddressMap = _topix4control.getIfAddresses();
    QString selectedItem = ui->comboBox_ownIPAdresses->currentText();

    // clean the current list first
    while ( ui->comboBox_ownIPAdresses->count() > 0 ) {
        ui->comboBox_ownIPAdresses->removeItem(0);
    }

    std::map<std::string,std::string>::iterator it;
    QString currentItem;
    for ( it = _hostAddressMap.begin(); it != _hostAddressMap.end(); it++ ) {
        // skip localhost and loopback devices
        if ( (*it).first.compare("127.0.0.1") == 0 ||
             (*it).second.compare("lo0") == 0 ||
             (*it).second.compare("lo") == 0 )
            continue;

        currentItem = QString("%1 (%2)").arg( (*it).first.c_str() ).arg( (*it).second.c_str() );
        ui->comboBox_ownIPAdresses->addItem( currentItem );

        // set the selected item to the old one
        if ( !selectedItem.isEmpty() && currentItem.compare(selectedItem) == 0 )
            ui->comboBox_ownIPAdresses->setCurrentIndex( ui->comboBox_ownIPAdresses->count()-1 );
    }
}

void MainWindow::on_toolButton_refreshOwnIP_1_clicked() {
    _hostAddressMap = _topix4control.getIfAddresses();
    QString selectedItem = ui->comboBox_ownIPAdresses_FairMQ->currentText();

    // clean the current list first
    while ( ui->comboBox_ownIPAdresses_FairMQ->count() > 0 ) {
        ui->comboBox_ownIPAdresses_FairMQ->removeItem(0);
    }

    std::map<std::string,std::string>::iterator it;
    QString currentItem;
    for ( it = _hostAddressMap.begin(); it != _hostAddressMap.end(); it++ ) {
        // skip localhost and loopback devices
        if ( (*it).first.compare("127.0.0.1") == 0 ||
             (*it).second.compare("lo0") == 0 ||
             (*it).second.compare("lo") == 0 )
            continue;

        currentItem = QString("%1 (%2)").arg( (*it).first.c_str() ).arg( (*it).second.c_str() );
        ui->comboBox_ownIPAdresses_FairMQ->addItem( currentItem );

        // set the selected item to the old one
        if ( !selectedItem.isEmpty() && currentItem.compare(selectedItem) == 0 )
            ui->comboBox_ownIPAdresses_FairMQ->setCurrentIndex( ui->comboBox_ownIPAdresses_FairMQ->count()-1 );
    }
}

void MainWindow::on_pushButton_Ping_clicked() {
    QIcon pingResultGood(":/icons/Check.png");
    QIcon pingResultBad(":/icons/Delete.png");

    if ( _topix4control.deviceIsOnline() ) {
        ui->label_pingResponseIcon->setPixmap( pingResultGood.pixmap(16,16) );

//        _topixcrtl.write(0x4C8, 2);
//        _topixcrtl.write(0x420, 1);
//        _topixcrtl.write(0x420, 2);
//        _topixcrtl.write(0x420, 3);
//        _topixcrtl.write(0x420, 4);
//        _topixcrtl.write(0x420, 5);
//        _topixcrtl.write(0x420, 6);
//        _topixcrtl.write(0x420, 7);
//        _topixcrtl.write(0x420, 8);
//        _topixcrtl.write(0x420, 9);
//        _topixcrtl.write(0x420, 10);
//        _topixcrtl.write(0x008, 10);

    } else {
        ui->label_pingResponseIcon->setPixmap( pingResultBad.pixmap(16,16) );
    }
}



// *************************************************************************************
//tab chip configuration
// *************************************************************************************

void MainWindow::on_pushButton_topix4cancelcommand_clicked()
{
    fillItemTable(_topix4ccr.getConstItemIteratorBegin(), _topix4ccr.getConstItemIteratorEnd(), *ui->tableWidget_topix3_ccr_write);
}

void MainWindow::on_pushButton_topix4clearcommand_clicked()
{
    clearItemTable(getIteratorItemCount(_topix4ccr.getConstItemIteratorBegin(), _topix4ccr.getConstItemIteratorEnd()),*ui->tableWidget_topix3_ccr_write);
    fillItemTable(_topix4ccr.getConstItemIteratorBegin(), _topix4ccr.getConstItemIteratorEnd(), *ui->tableWidget_topix3_ccr_write);
}

void MainWindow::on_pushButton_topix4sendcommand_clicked()
{
    assignItemValues(_topix4ccr, *ui->tableWidget_topix3_ccr_write);
    _topix4ccr.assemble();
    _topix4control.configCCR(_topix4ccr, ui->lineEdit_readbacklength->text().toUInt());
   // Error();
}

void MainWindow::on_pushButton_topix4loadcommand_clicked()
{
    _topix4ccr.setCommand(topix4_ccrnumber::ccr0,32);
    _topix4ccr.setCommand(topix4_ccrnumber::ccr1,33);
    _topix4ccr.setCommand(topix4_ccrnumber::ccr2,34);

    _topix4ccr.setLocalItemValue("CounterEnable",1);
    _topix4ccr.setLocalItemValue("FreezeStop",4);
    _topix4ccr.setLocalItemValue("CounterStopValue",4095);

    on_pushButton_topix4clearcommand_clicked();
}

void MainWindow::on_pushButton_topix4loadcommand_richard_clicked()
{
    _topix4ccr.setCommand(topix4_ccrnumber::ccr0,32);
    _topix4ccr.setCommand(topix4_ccrnumber::ccr1,33);
    _topix4ccr.setCommand(topix4_ccrnumber::ccr2,34);

    _topix4ccr.setLocalItemValue("CounterMode",1);
    _topix4ccr.setLocalItemValue("CounterEnable",1);
    _topix4ccr.setLocalItemValue("ReadoutCycleHalfSpeed",1);
    _topix4ccr.setLocalItemValue("FreezeStop",4);

    _topix4ccr.setLocalItemValue("Leak_P",1);
    _topix4ccr.setLocalItemValue("SelectPol",1);
    _topix4ccr.setLocalItemValue("PreEmphasisTimeStamp",1);
    _topix4ccr.setLocalItemValue("PreEmphasisCommands",1);

    _topix4ccr.setLocalItemValue("CounterStopValue",4095);

    on_pushButton_topix4clearcommand_clicked();
}



void MainWindow::on_pushButton_topix4readccr0_clicked()
{
    _topix4control.readCCR0(_topix4ccrread);
    _topix4ccrread.disassemble();

    clearItemTable(getIteratorItemCount(_topix4ccrread.getConstItemIteratorBegin(), _topix4ccrread.getConstItemIteratorEnd()),*ui->tableWidget_topix3_ccr_read);
    fillItemTable(_topix4ccrread, *ui->tableWidget_topix3_ccr_read);
    Error();
}

void MainWindow::on_pushButton_topix4readccr1_clicked()
{
    _topix4ccrread.clearDataStream();
    _topix4control.readCCR1(_topix4ccrread);
    _topix4ccrread.disassemble();

    clearItemTable(getIteratorItemCount(_topix4ccrread.getConstItemIteratorBegin(), _topix4ccrread.getConstItemIteratorEnd()),*ui->tableWidget_topix3_ccr_read);
    fillItemTable(_topix4ccrread, *ui->tableWidget_topix3_ccr_read);
    Error();
}

void MainWindow::on_pushButton_topix4readccr2_clicked()
{
    _topix4control.readCCR2(_topix4ccrread);
    _topix4ccrread.disassemble();

    clearItemTable(getIteratorItemCount(_topix4ccrread.getConstItemIteratorBegin(), _topix4ccrread.getConstItemIteratorEnd()),*ui->tableWidget_topix3_ccr_read);
    fillItemTable(_topix4ccrread, *ui->tableWidget_topix3_ccr_read);
    Error();
}



void MainWindow::on_pushButton_topix4readccr_clicked()
{
    _topix4control.readCCR0(_topix4ccrread);
    _topix4ccrread.disassemble();
    _topix4control.readCCR1(_topix4ccrread);
    _topix4ccrread.disassemble();
    _topix4control.readCCR2(_topix4ccrread);
    _topix4ccrread.disassemble();

    clearItemTable(getIteratorItemCount(_topix4ccrread.getConstItemIteratorBegin(), _topix4ccrread.getConstItemIteratorEnd()),*ui->tableWidget_topix3_ccr_read);
    fillItemTable(_topix4ccrread, *ui->tableWidget_topix3_ccr_read);
    Error();
}

void MainWindow::on_pushButton_topix4clearread_clicked()
{
    clearItemTable(getIteratorItemCount(_topix4ccrread.getConstItemIteratorBegin(), _topix4ccrread.getConstItemIteratorEnd()),*ui->tableWidget_topix3_ccr_read);
    _topix4ccrread.clearDataStream();
    _topix4ccrread.disassemble();
    fillItemTable(_topix4ccrread, *ui->tableWidget_topix3_ccr_read);
}

// *************************************************************************************
//tab pixel configuration
// *************************************************************************************

void MainWindow::on_pushButton_readnextpixel_clicked()
{


    _topix4command.setOperationCode(topix4_command::readpixelconfiguration);
    _topix4command.assemble();
 //   _pixelconfig.setPixCommand(0,pixel,topix4_command::readpixelconfiguration);
  //  _pixelconfig.assemble(sel,pixel);
    _topix4control.writeRemoteData(_topix4command);
 //   _pixelconfig.setPixCommand(sel,pixel,topix4_command::nooperation);
 //   _pixelconfig.assemble(sel,pixel);
    _topix4command.setOperationCode(topix4_command::nooperation);
    _topix4command.assemble();
    _topix4control.writeRemoteData(_topix4command);

    _topix4command.setOperationCode(topix4_command::movetonextpixel);
    _topix4command.assemble();
    _topix4control.writeRemoteData(_topix4command);

    _topix4control.boardCommand(tpxctrl_value::topix4config);
    _topix4control.read(tpx_address::sdataout);

    _pixelreadback.setWord(0,_topix4control.read(tpx_address::sdataout));

    _topix4control.read(tpx_address::sdataout);

    _pixelreadback.disassemble();
    ui->textEdit_readbackpixelconfiguration->append( " Operation Command " +QString::number(_pixelreadback.getOperationCode())+ " DAC " + QString::number(_pixelreadback.getThresholdDAC()) + " TestPuls " + QString::number(_pixelreadback.getTestPulsEnable()) + " Comparator "+ QString::number(_pixelreadback.getComparatorTestOutEnable())  + " Mask " + QString::number(_pixelreadback.getPixelMask()) );
    ui->textEdit_readbackpixelconfiguration->append(QString::number((u_int16_t)_pixelreadback.getWord(0),16));
}

void MainWindow::on_pushButton_readbackpixelconfiguration_clicked()
{
    selectcolumn(0);

    on_pushButton_configmode_clicked();

    for(int sel=0;sel<_pixelconfig.getColumnCount();sel++)
    {
        selectcolumn(sel);
        ui->textEdit_readbackpixelconfiguration->append("################ sel " + sel);
        _topix4command.setOperationCode(topix4_command::movetonextpixel);
        _topix4command.assemble();

        for(int pixel=_pixelconfig.getRowCount(sel)-1;pixel>-1;pixel--)
        {

            std::cout << "_pixelconfig.getRowCount(sel) " << _pixelconfig.getRowCount(sel) << " sel " << sel << " pixel " << pixel <<std::endl;
            _pixelconfig.setPixCommand(sel,pixel,topix4_command::readpixelconfiguration);
            _pixelconfig.assemble(sel,pixel);
            _topix4control.writeRemoteData(_pixelconfig);

            _pixelconfig.setPixCommand(sel,pixel,topix4_command::nooperation);
            _pixelconfig.assemble(sel,pixel);
            _topix4control.writeRemoteData(_pixelconfig);

            _topix4control.writeRemoteData(_topix4command);

            _topix4control.boardCommand(tpxctrl_value::topix4config);
            _topix4control.read(tpx_address::sdataout);
            _topix4control.read(tpx_address::sdataout);
            _pixelreadback.setWord(0,_topix4control.read(tpx_address::sdataout));

            _pixelreadback.disassemble();
            ui->textEdit_readbackpixelconfiguration->append("Loop Number " + QString::number(pixel) + " Operation Code " + QString::number(_pixelreadback.getOperationCode()) + " DAC " + QString::number(_pixelreadback.getThresholdDAC())+  " Comparator "+ QString::number(_pixelreadback.getComparatorTestOutEnable())  + " TestPuls " + QString::number(_pixelreadback.getTestPulsEnable()) + " Mask " + QString::number(_pixelreadback.getPixelMask()) );
            ui->textEdit_readbackpixelconfiguration->append(QString::number((u_int16_t)_pixelreadback.getWord(0),16));

        }

    }

    on_pushButton_normalmode_clicked();
}

void MainWindow::on_pushButton_selectcolumn0_clicked()
{
    selectcolumn(0);
}

void MainWindow::on_pushButton_selectcolumn1_clicked()
{
    selectcolumn(1);
}

void MainWindow::on_pushButton_selectcolumn2_clicked()
{
    selectcolumn(2);
}

void MainWindow::on_pushButton_selectcolumn3_clicked()
{
    selectcolumn(3);
}

void MainWindow::on_pushButton_selectcolumn4_clicked()
{
    selectcolumn(4);
}

void MainWindow::on_pushButton_selectcolumn5_clicked()
{
    selectcolumn(5);
}

void MainWindow::on_pushButton_selectcolumn6_clicked()
{
    selectcolumn(6);
}

void MainWindow::on_pushButton_selectcolumn7_clicked()
{
    selectcolumn(7);
}

void MainWindow::selectcolumn(int column)
{
    _topix4command.setOperationCode(topix4_command::columnselection);
    _topix4command.setData(column);
    _topix4command.assemble();
    _topix4control.writeToChip(_topix4command);
    Error();
}

void MainWindow::on_pushButton_configmode_clicked()
{
    _topix4command.setOperationCode(topix4_command::configmodeoperation);
    _topix4command.assemble();
    _topix4control.writeToChip(_topix4command);
    Error();
}

void MainWindow::on_pushButton_normalmode_clicked()
{
    _topix4command.setOperationCode(topix4_command::normaloperation);
    _topix4command.assemble();
    _topix4control.writeToChip(_topix4command);
    Error();
}

void MainWindow::clearPixelConfigTable(QTableWidget& table, int columnwidth, int rowheight)
{
    table.clear();
    table.setColumnCount(32);
    table.setRowCount(20);
    QStringList list;
    list.clear();

    for(int j=_pixelconfig.getMatrixRows()-1; j>-1;j--)
    {
        list << QString::number(j);
    }
    table.setVerticalHeaderLabels(list);

    list.clear();
    for(int j=_pixelconfig.getMatrixCols()-1; j>-1;j--)
    {
        list << QString::number(j);
    }
    table.setHorizontalHeaderLabels(list);
    for(int i=0; i<32; i++)
    {
        table.setColumnWidth(i,columnwidth);
    }

    for(int i=0; i<20; i++)
    {
        table.setRowHeight(i,rowheight);
    }
}

void MainWindow::p3testpulsfillItemTable()
{
    for(unsigned int row=0; row < 20; row++)
    {
        for(unsigned int column =0 ; column < 32 ; column++)
        {
            QTableWidgetItem *item = new QTableWidgetItem(QString::number(_pixelconfig.getPixTestPulsEnable(column,row,true)),0);
            //item ->setBackgroundColor(Qt::green);
            itemcolormatrix(item);
            ui->tableWidget_p3testpulstest->setItem(row,column,item);
        }
    }
}

void MainWindow::on_pushButton_p3maskapply_clicked()
{
    p3maskassignItemValues();
}

void MainWindow::p3maskassignItemValues()
{
    {
        for(unsigned int row=0; row < 20; row++)
        {
            for(unsigned int column =0 ; column < 32 ; column++)
            {
                _pixelconfig.setPixMask(column,row,ui->tableWidget_p3masktest->item(row,column)->text().toUInt(),true);
            }
        }
    }
}

void MainWindow::p3comparatorassignItemValues()
{
    {
        for(unsigned int row=0; row < 20; row++)
        {
            for(unsigned int column =0 ; column < 32 ; column++)
            {
                _pixelconfig.setPixComparatorEnable(column,row,ui->tableWidget_p3comparatortest->item(row,column)->text().toUInt(),true);
            }
        }
    }
}

void MainWindow::p3pdacassignItemValues()
{
    if(pdacstartup!=true)
    {
        {
            for(unsigned int row=0; row < 20; row++)
            {
                for(unsigned int column =0 ; column < 32 ; column++)
                {
                    if(ui->tableWidget_p3pdactest->item(row,column)->text() ==QString("-0"))
                    {
                        _pixelconfig.setPixPDAC(column,row,abs(ui->tableWidget_p3pdactest->item(row,column)->text().toInt()),true);
                        _pixelconfig.setPixPDACSign(column,row,1,true);
                      //  std::cout << "miunus 0 gesehen " << ui->tableWidget_p3pdactest->item(row,column)->text().toStdString() << std::endl;
                    }

                    else if(ui->tableWidget_p3pdactest->item(row,column)->text().toInt()<0)
                    {
                        _pixelconfig.setPixPDAC(column,row,abs(ui->tableWidget_p3pdactest->item(row,column)->text().toInt()),true);
                        _pixelconfig.setPixPDACSign(column,row,1,true);
                    }
                    else if(ui->tableWidget_p3pdactest->item(row,column)->text().toInt()>0)
                    {
                        _pixelconfig.setPixPDAC(column,row,abs(ui->tableWidget_p3pdactest->item(row,column)->text().toInt()),true);
                        _pixelconfig.setPixPDACSign(column,row,0,true);
                    }

                    else if(ui->tableWidget_p3pdactest->item(row,column)->text().toInt()==0)
                    {
                        _pixelconfig.setPixPDAC(column,row,abs(ui->tableWidget_p3pdactest->item(row,column)->text().toInt()),true);
                        _pixelconfig.setPixPDACSign(column,row,0,true);
                    }
                    else
                    {}

                }
            }
        }
    }
}

void MainWindow::p3testpulsassignItemValues()
{
    {
        for(unsigned int row=0; row < 20; row++)
        {
            for(unsigned int column =0 ; column < 32 ; column++)
            {
                _pixelconfig.setPixTextPulsEnable(column,row,ui->tableWidget_p3testpulstest->item(row,column)->text().toUInt(),true);
            }
        }
    }
}

void MainWindow::on_pushButton_p3savesettingstofile_clicked()
{
    QFile output;
    if (ui->lineEdit_p3savefilename->text()!= 0)
    {
        output.setFileName(ui->lineEdit_p3savefilename->text());
    }
    else
    {
        ui->textEdit_Info->append("No Filename given");
        return;
    }

    if(output.open(QIODevice::WriteOnly) == true)
    {
        ui->textEdit_Info->append("File successfully opened");
        ui->textEdit_Info->append(QString::number(output.error()));

        // todo: print error description to error number in info textEdit
    }
    else
    {
        ui->textEdit_Info->append("File not opended");
        ui->textEdit_Info->append(QString::number(output.error()));
    }
    std::map<const std::string, TConfItem>::const_iterator iter;
    QTextStream stream;
    stream.setDevice(&output);

    for(int i =0; i< _pixelconfig.getColumnCount(); i++)
    {
        for(int j=0; j< _pixelconfig.getRowCount(i); j++)
        {
            for(iter=_pixelconfig.getConstItemIteratorBegin(i,j);iter != _pixelconfig.getConstItemIteratorEnd(i,j);iter++)
            {
                stream << iter->second.value << " ";
            }
            stream << "\n";
        }
    }
    output.close();
}

void MainWindow::on_pushButton_p3maskmaskallpixel_clicked()
{
    for(int i =0; i< _pixelconfig.getColumnCount(); i++)
    {
        for(int j=0; j< _pixelconfig.getRowCount(i); j++)
        {
            _pixelconfig.setPixMask(i,j,1,false);
        }
    }
    on_pushButton_p3maskclear_clicked();
}

void MainWindow::on_pushButton_p3maskunmaskallpixel_clicked()
{
    for(int i =0; i< _pixelconfig.getColumnCount(); i++)
    {
        for(int j=0; j< _pixelconfig.getRowCount(i); j++)
        {
            _pixelconfig.setPixMask(i,j,0,false);
        }
    }
    on_pushButton_p3maskclear_clicked();
}

void MainWindow::on_pushButton_p3loadsettingsfromfile_clicked()
{
    QFile output;
    if (ui->lineEdit_p3savefilename->text()!= 0)
    {
        output.setFileName(ui->lineEdit_p3savefilename->text());
    }
    else
    {
        ui->textEdit_Info->append("No Filename given");
        return;
    }

    if(output.open(QIODevice::ReadOnly) == true)
    {
        ui->textEdit_Info->append("File successfully opened");
        ui->textEdit_Info->append(QString::number(output.error()));

        // todo: print error description to error number in info textEdit
    }
    else
    {
        ui->textEdit_Info->append("File not opended");
        ui->textEdit_Info->append(QString::number(output.error()));
    }
    std::map<const std::string, TConfItem>::iterator iter;
    QTextStream stream;
    stream.setDevice(&output);
    for(int i =0; i< _pixelconfig.getColumnCount(); i++)
    {
        for(int j=0; j< _pixelconfig.getRowCount(i); j++)
        {
            for(iter=_pixelconfig.getItemIteratorBegin(i,j);iter != _pixelconfig.getItemIteratorEnd(i,j);iter++)
            {
                stream >> iter->second.value;
            }
        }
    }
    output.close();
    on_pushButton_p3maskclear_clicked();
    p3testpulsclear();
    on_pushButton_p3pdacclear_clicked();
}

void MainWindow::on_pushButton_p3testpulsdisableall_clicked()
{
    for(int i =0; i< _pixelconfig.getColumnCount(); i++)
    {
        for(int j=0; j< _pixelconfig.getRowCount(i); j++)
        {
            _pixelconfig.setPixTextPulsEnable(i,j,0,false);
        }
    }
    p3testpulsclear();
}

void MainWindow::on_pushButton_p3maskclear_clicked()
{
    clearPixelConfigTable(*ui->tableWidget_p3masktest,20,20);
    p3maskfillItemTable();
}

void MainWindow::p3testpulsclear()
{

    clearPixelConfigTable(*ui->tableWidget_p3testpulstest,20,20);
    p3testpulsfillItemTable();
}

void MainWindow::p3maskfillItemTable()
{
    for(unsigned int row=0; row < 20; row++)
    {
        for(unsigned int column =0 ; column < 32 ; column++)
        {
            QTableWidgetItem *item = new QTableWidgetItem(QString::number(_pixelconfig.getPixMask(column,row,true)),0);
            itemcolormatrix(item);
            ui->tableWidget_p3masktest->setItem(row,column,item);
        }
    }
}

void MainWindow::p3comparatorfillItemTable()
{
    for(unsigned int row=0; row < 20; row++)
    {
        for(unsigned int column =0 ; column < 32 ; column++)
        {
            QTableWidgetItem *item = new QTableWidgetItem(QString::number(_pixelconfig.getPixComparatorEnable(column,row,true)),0);
            itemcolormatrix(item);
            ui->tableWidget_p3comparatortest->setItem(row,column,item);
        }
    }
}

void MainWindow::p3pdacfillItemTable()
{
    pdacstartup=true;
    for(unsigned int row=0; row < 20; row++)
    {
        for(unsigned int column =0 ; column < 32 ; column++)
        {
            QTableWidgetItem *item = new QTableWidgetItem(QString::number(_pixelconfig.getPixPDAC(column,row,true)),0);
            //QString zahl;
            //if(_pixelconfig.getPixPDACSign(column,row,true)== 1)
            //{
            //    zahl.append("-");
            //}
            //zahl.append(QString::number(_pixelconfig.getPixPDAC(column,row,true)));
            //QTableWidgetItem *item = new QTableWidgetItem(zahl,0);
            //itemcolormatrix(item);
            ui->tableWidget_p3pdactest->setItem(row,column,item);
        }
    }
    pdacstartup=false;
}

void MainWindow::fillPixelConfigTable(QTableWidget& table)
{
    for(unsigned int row=0; row < 20; row++)
    {
        for(unsigned int column =0 ; column < 32 ; column++)
        {
            QTableWidgetItem *item = new QTableWidgetItem(QString::number(0),0);
            item ->setBackgroundColor(Qt::green);
            table.setItem(row,column,item);
        }
    }
}

void MainWindow::on_tableWidget_p3testpulstest_cellClicked(int row, int column)
{
    ui->textEdit_Info->append("row " + QString::number(row) + " column " + QString::number(column) );
    QTableWidgetItem *blubb =  ui->tableWidget_p3testpulstest->item(row, column);

    if(blubb->text().toUInt() == 0)
    {
        blubb->setText(QString::number(1));
    }
    else
    {
        blubb->setText(QString::number(0));
    }
    itemcolormatrix(blubb);
    p3testpulsassignItemValues();
}

void MainWindow::on_tableWidget_p3masktest_cellClicked(int row, int column)
{
   // ui->textEdit_Info->append("row " + QString::number(row) + " column " + QString::number(column) );
    QTableWidgetItem *blubb =  ui->tableWidget_p3masktest->item(row, column);

    if(blubb->text().toUInt() == 0)
    {
        blubb->setText(QString::number(1));
    }
    else
    {
        blubb->setText(QString::number(0));
    }
    itemcolormatrix(blubb);
    on_pushButton_p3maskapply_clicked();
}

void MainWindow::config_all_with_individual_settings()
{
//    bool turnon=false;
//    if(readout==true)
 //   {
//        turnon=true;
//       readout=false;
 //   }

    selectcolumn(0);

    on_pushButton_configmode_clicked();

    for(int sel=1;sel<_pixelconfig.getColumnCount();sel++)
    {
        selectcolumn(sel);

        //std::cout << "_pixelconfig.getRowCount(sel) " << _pixelconfig.getRowCount(sel) << " sel " << sel <<std::endl;
        _topix4command.setOperationCode(topix4_command::movetonextpixel);
        _topix4command.assemble();

        for(int pixel=_pixelconfig.getRowCount(sel)-1;pixel>-1;pixel--)
            //for(int pixel=0;pixel<_pixelconfig.getRowCount(sel);pixel++)
        {
             std::cout << "_pixelconfig.getRowCount(sel) " << _pixelconfig.getRowCount(sel) << " sel " << sel << " pixel " << pixel <<std::endl;
            _pixelconfig.setPixCommand(sel,pixel,topix4_command::writepixelconfiguration);
            _pixelconfig.assemble(sel,pixel);
            _topix4control.writeRemoteData(_pixelconfig);
            _topix4control.writeRemoteData(_topix4command);
            _topix4control.boardCommand(tpxctrl_value::topix4config);
            _topix4control.read(tpx_address::sdataout);
            _topix4control.read(tpx_address::sdataout);
        }
    }

    on_pushButton_normalmode_clicked(); //Enters a mode that allows testing and scans and such (leaves config mode)

 //   if(turnon==true)
  //  {
  //      readout=true;
  //      turnon=false;
  //  }
    Error();
}

void MainWindow::on_pushButton_p3configtopix_clicked()
{
    p3maskassignItemValues();
    p3pdacassignItemValues();
    p3comparatorassignItemValues();
    p3testpulsassignItemValues();
    config_all_with_individual_settings();
}

void MainWindow::on_pushButton_p3pdacclear_clicked()
{
    clearPixelConfigTable(*ui->tableWidget_p3pdactest,27,25);
    p3pdacfillItemTable();
}

void MainWindow::on_pushButton_p3configtothreshold_clicked()
{
    int Max_Pixel=0;
    int Best_DAC=0, Best_DAC_Sign=0;

    for(int s=0; s<8 ; s++)
    {
        if(s == 0 || s==1 || s==6 || s==7)
        {
            Max_Pixel=32;
        }
        else if(s==2 || s==3 || s==4 || s==5)
        {
            Max_Pixel=128;
        }

        for(int p=0; p < Max_Pixel; p++)
        {
            //Get_Best_Pixel_DAC(s,p,ui->lineEdit_p3configtothresholdthreshold->text().toUInt(),Best_DAC_Sign,Best_DAC,ui->lineEdit_p3configtothresholdfilename->text());

            std::cout << "Sel " << s<< " Pixel " << p << " Best_DAC " << Best_DAC<< " Best_DAC_Sign " << Best_DAC_Sign << std::endl;
            _pixelconfig.setPixPDAC(s,p,Best_DAC,false);
            _pixelconfig.setPixPDACSign(s,p,Best_DAC_Sign,false);

            qApp->processEvents();
        }
    }
    p3pdacfillItemTable();

}

void MainWindow::on_pushButton_p3allclear_clicked()
{
    on_pushButton_p3pdacclear_clicked();
    on_pushButton_p3testpulsdisableall_clicked();
    on_pushButton_p3comparatorclear_clicked();
    on_pushButton_p3maskclear_clicked();
}

void MainWindow::on_pushButton_p3comparatorclear_clicked()
{
    clearPixelConfigTable(*ui->tableWidget_p3comparatortest,20,20);
    p3comparatorfillItemTable();
}

void MainWindow::on_pushButton_p3pdacsetalltozero_clicked()
{
    for(int i =0; i< _pixelconfig.getColumnCount(); i++)
    {
        for(int j=0; j< _pixelconfig.getRowCount(i); j++)
        {
            _pixelconfig.setPixPDAC(i,j,0,false);
            //_pixelconfig.setPixPDACSign(i,j,0,false);
        }
    }
    on_pushButton_p3pdacclear_clicked();
}

void MainWindow::on_pushButton_p3pdacsetallto15_clicked()
{
    for(int i =0; i< _pixelconfig.getColumnCount(); i++)
    {
        for(int j=0; j< _pixelconfig.getRowCount(i); j++)
        {
            _pixelconfig.setPixPDAC(i,j,15,false);
           // _pixelconfig.setPixPDACSign(i,j,0,false);
        }
    }
    on_pushButton_p3pdacclear_clicked();
}


void MainWindow::on_tableWidget_p3pdactest_cellChanged(int row, int column)
{
    if( ui->tableWidget_p3pdactest->item(row,column)->text().toInt()>15 ||ui->tableWidget_p3pdactest->item(row,column)->text().toInt()<-15)
    {
        ui->textEdit_Info->append("PDAC Value Outside Specifications");
        QTableWidgetItem *item = ui->tableWidget_p3pdactest->item(row,column);
        //item->setText(assamblePDAC(row,column));
        ui->tableWidget_p3pdactest->setItem(row,column,item);
    }
    else
    {
        p3pdacassignItemValues();
    }
}

// *************************************************************************************
// Measurements
// *************************************************************************************

void MainWindow::measurement_tot_linearity(int start, int stop, int stepwidth, int numberofinjections)
{
    // todo flush main fifo

    // todo start state machine

    for(int i=start;i<stop;i+=stepwidth)
    {
        setCalLevel(i);
        for(int j=0;j< numberofinjections;j++)
        {
            injectChargeInternalUnsync();
            usleep(10); // just to make sure everything is processed
        }
    }
}
