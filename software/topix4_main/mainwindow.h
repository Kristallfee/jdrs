#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTableWidget>
#include "mrfdata_chain2ltc2604.h"
#include "mrfcal_topix4.h"
#include "mrfdata_tpx4pixelmatrix.h"
#include "mrfstrerror.h"
#include "topix4_fairmq_readout.h"




namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT
    
public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();
    void DoFairMQReadout();


private:
    Ui::MainWindow *ui;
    QString appauthor;
    QString appname;
    TMrfData_Chain2LTC2604 _ltc2604;
    TMrfCal_Topix4 _topix4control;
    TMrfData_Topix4Config _topix4ccr;          // container for all ccr settings
    TMrfData_Topix4Config _topix4ccrread;      // container for readback ccr settings
    TMrfStrError* _errorstrcon;
    TMrfData_Tpx4PixelMatrix _pixelconfig;
    std::map<std::string,std::string> _hostAddressMap;
    uint GetAddress(QString);
    bool pdacstartup;
    bool readout;

    bool Error();
    void Print(const QString& str);
    void config_all_with_individual_settings();


    bool _end_readout;

        ToPix4_FairMQ_Readout fairmqreadout;

private slots:

        void on_pushButton_ConfigFakeData_clicked();

        void on_pushButton_start_fairmq_sm_clicked();
        void on_pushButton_pause_fairmq_sm_clicked();
        void on_pushButton_start_fairmq_thread_clicked();
        void on_pushButton_stop_fairmq_thread_clicked();
        void on_pushButton_stop_fairmq_sm_clicked();

        void itemcolormatrix(QTableWidgetItem *item, int range=1);

        //connection UDP
        void on_pushButton_Connect_UDP_clicked();
        void on_pushButton_Disconnect_UDP_clicked();
        void on_toolButton_refreshOwnIP_clicked();
        void on_pushButton_Ping_clicked();

    //Register
    void on_pushButton_Writeregister_clicked();
    void on_pushButton_Readregister_clicked();
    void on_pushButton_Writeregister_2_clicked();
    void on_pushButton_Readregister_2_clicked();
    void on_pushButton_Readdmadata_clicked();
    void on_pushButton_cleardmadata_clicked();
    void on_pushButton_fillFifo_clicked();
    void on_pushButton_Configmmcm_clicked();

    //ltc2604
    void on_pushButton_ltc2604clear_clicked();
    void on_pushButton_ltc2604cancel_clicked();
    void on_pushButton_configureltc2604_clicked();
    void on_pushButton_ltc2604clearcommand_clicked();
    void on_pushButton_ltc2604cancelcommand_clicked();
    void on_pushButton_ltc2604sendcommand_clicked();
    void on_pushButton_ltc2604loadmodule4_clicked();

    //CCR (global) register
    void on_pushButton_topix4sendcommand_clicked();
    void on_pushButton_topix4cancelcommand_clicked();
    void on_pushButton_topix4clearcommand_clicked();
    void on_pushButton_topix4readccr_clicked();
    void on_pushButton_topix4clearread_clicked();

    //Pixel Register
    void on_pushButton_p3maskapply_clicked();
    void on_pushButton_p3allclear_clicked();
    void on_pushButton_p3maskclear_clicked();
    void on_pushButton_p3pdacclear_clicked();
   // void on_pushButton_p3comparatorclear_clicked();
    void on_pushButton_p3testpulsdisableall_clicked();
    void on_tableWidget_p3masktest_cellClicked(int row, int column);
    void on_tableWidget_p3testpulstest_cellClicked(int row, int column);
  //  void on_tableWidget_p3comparatortest_cellClicked(int row, int column);
    void p3maskfillItemTable();
    void p3testpulsclear();
    void on_pushButton_p3pdacsetalltozero_clicked();
    void on_tableWidget_p3pdactest_cellChanged(int row, int column);
   // QString assamblePDAC(int row, int column);
    void p3comparatorfillItemTable();
    void p3testpulsfillItemTable();
    void on_pushButton_p3configtopix_clicked();
    void p3maskassignItemValues();
    void on_pushButton_p3savesettingstofile_clicked();
    void on_pushButton_p3loadsettingsfromfile_clicked();
   // void clearPixelConfigTable(QTableWidget& table, int columnwidth, int rowheight);
    void fillPixelConfigTable(QTableWidget& table);
    void on_pushButton_p3maskmaskallpixel_clicked();
    void on_pushButton_p3maskunmaskallpixel_clicked();
    void p3pdacfillItemTable();
    void p3comparatorassignItemValues();
    void p3testpulsassignItemValues();
    void p3pdacassignItemValues();
    void on_pushButton_p3configtothreshold_clicked();

};

#endif // MAINWINDOW_H
