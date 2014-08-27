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
    _end_readout = false;
    on_toolButton_refreshOwnIP_clicked();

}

MainWindow::~MainWindow()
{
    fairmqreadout.ChangeState(ToPix4_FairMQ_Readout::END);
    delete ui;
}

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
    //fairmqreadout.ChangeState(ToPix4_FairMQ_Readout::Shutdown());
}

void MainWindow::DoFairMQReadout()
{
    if (_topix4control.deviceIsOpen())
    {
       on_pushButton_Disconnect_UDP_clicked();
    }

    QStringList ownIP = ui->comboBox_ownIPAdresses->currentText().split(" ");
    QString connectionParameter = QString("%1,%2,%3,%4")
            .arg(ownIP[0])
            .arg(ui->spinBox_ownPort->value())
            .arg(ui->lineEdit_remoteIPAddress->text())
            .arg(ui->spinBox_remotePort->value());

    FairMQTransportFactory* transportFactory = new FairMQTransportFactoryZMQ();

    fairmqreadout.SetOutputWindow(ui->textEdit_Dmadata);
    fairmqreadout.SetTransport(transportFactory);
    fairmqreadout.SetProperty(ToPix4_FairMQ_Readout::Id, 100);
    fairmqreadout.SetProperty(ToPix4_FairMQ_Readout::EventSize, ui->lineEdit_fairmq_message_size->text().toInt()); //in 40 bit words
    fairmqreadout.SetProperty(ToPix4_FairMQ_Readout::NumIoThreads, 1);
    fairmqreadout.SetProperty(ToPix4_FairMQ_Readout::NumInputs, 0);
    fairmqreadout.SetProperty(ToPix4_FairMQ_Readout::NumOutputs, 1);

    fairmqreadout.ChangeState(ToPix4_FairMQ_Readout::INIT);

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
      // ui->textEdit_Dmadata->append(QString::fromStdString(tempdaten.exportBinString()));
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
    _ltc2604.setDACValue("LTC1","DACA",45524);
    _ltc2604.setDACValue("LTC1","DACB",40219);
    _ltc2604.setDACValue("LTC1","DACC",37516);
    _ltc2604.setDACValue("LTC1","DACD",34850);
    _ltc2604.setDACValue("LTC2","DACA",38616);
    on_pushButton_ltc2604clear_clicked();
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
    //clearPixelConfigTable(*ui->tableWidget_p3masktest,20,20);
    p3maskfillItemTable();
}

void MainWindow::p3testpulsclear()
{
    //clearPixelConfigTable(*ui->tableWidget_p3testpulstest,20,20);
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
            //QTableWidgetItem *item = new QTableWidgetItem(QString::number(_pixelconfig.getPixPDAC(column,row,true)),0);
            QString zahl;
            if(_pixelconfig.getPixPDACSign(column,row,true)== 1)
            {
                zahl.append("-");
            }
            zahl.append(QString::number(_pixelconfig.getPixPDAC(column,row,true)));
            QTableWidgetItem *item = new QTableWidgetItem(zahl,0);
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

void MainWindow::on_pushButton_p3configtopix_clicked()
{
    p3maskassignItemValues();
    p3pdacassignItemValues();
    p3comparatorassignItemValues();
    p3testpulsassignItemValues();
    //config_all_with_individual_settings();
}

void MainWindow::on_pushButton_p3pdacclear_clicked()
{
    //clearPixelConfigTable(*ui->tableWidget_p3pdactest,27,25);
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
    //on_pushButton_p3comparatorclear_clicked();
    on_pushButton_p3maskclear_clicked();
}

void MainWindow::on_pushButton_p3pdacsetalltozero_clicked()
{
    for(int i =0; i< _pixelconfig.getColumnCount(); i++)
    {
        for(int j=0; j< _pixelconfig.getRowCount(i); j++)
        {
            _pixelconfig.setPixPDAC(i,j,0,false);
            _pixelconfig.setPixPDACSign(i,j,0,false);
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
