//+------------------------------------------------------------------+
//|                                         Walking up the bands.mq5 |
//|                                        André Luís Lopes da Silva |
//|                                      clonageinvitro@yahoo.com.br |
//+------------------------------------------------------------------+
#property copyright "André Luís Lopes da Silva"
#property link      "https://github.com/Andre-Luis-Lopes-da-Silva"
#property version   "1.00"

// Inclusão de bibliotecas utilizadas
#include <Trade/Trade.mqh>
#include <Trade/SymbolInfo.mqh>
  
input group              "Configurações gerais"
input ulong              Magic          = 123456;      // Magic Number
input group              "Configurações operacionais"
input double             Volume         = 100;         // Volume
input group              "Configurações do indicador"
input int                Periodo        = 20;          // Período
input double             Desvio         = 2;           // Desvio
input int                Deslocamento   = 0;           // Deslocar
input ENUM_APPLIED_PRICE Preco          = PRICE_CLOSE; // Preço Aplicado

int         handle;
string      shortname;
double      BBarray[];
double      Buffer[];
double superior[], inferior[];

CTrade      trade;   // Classe responsável pela execução de negócios
CSymbolInfo simbolo; // Classe responsãvel pelos dados do ativo

MqlRates velas[];            // Variável para armazenar velas
MqlTick tick;                // variável para armazenar ticks 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

// Definição do símbolo utilizado para a classe responsável
   if(!simbolo.Name(_Symbol))
     {
      printf("Ativo Inválido!");
      return INIT_FAILED;
     }
     
// Definição de número mágico
   trade.SetExpertMagicNumber(Magic);

// Criação dos manipulador
   handle = iBands(_Symbol, _Period, Periodo, Deslocamento, Desvio, Preco);
   
// Verificação do resultado da criação dos manipuladores
   if(handle == INVALID_HANDLE)
     {
      Print("Erro na criação dos manipuladores");
      return INIT_FAILED;
     }

   if(!ChartIndicatorAdd(0, 0, handle))
     {
      Print("Erro na adição do indicador ao gráfico");
      return INIT_FAILED;
     }
     
   shortname = ChartIndicatorName(0, 0, ChartIndicatorsTotal(0, 0)-1);
   
   return(INIT_SUCCEEDED);
  } 
//---
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ChartIndicatorDelete(0, 0, shortname);
   
// Motivo da desinicialização do EA
   printf("Deinit reason: %d", reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
bool pode_operar = true;

void OnTick()
  {
//---
    
    //--- Alimentar Buffers das Velas com dados:
    CopyRates(_Symbol,_Period,0,4,velas);
    ArraySetAsSeries(velas,true);
   
    // Alimentar com dados variável de tick
    SymbolInfoTick(_Symbol,tick);
   
    ArraySetAsSeries(superior, true);
    ArraySetAsSeries(inferior, true);
    CopyBuffer(handle, 1, 0, 3, superior);
    CopyBuffer(handle, 2, 0, 3, inferior);
   
    double close_atual = iClose(_Symbol, _Period, 0);
    double open_atual = iOpen(_Symbol, _Period, 0);
    double low_atual = iLow(_Symbol, _Period, 0);
    
    bool Comprar = false;
    bool Vender = false;
    
    // monitorar
    //calcualte EA for the current candle
 
    //define Ask, Bid
    double Ask = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
    double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
 
    double UpperBandValue=superior[0];
    double LowerBandValue=inferior[0];
    //comments
    Comment("UpperBandValue: ",UpperBandValue,"\n","LowerBandValue: ",LowerBandValue,"\n"," Ask: ", Ask);  
    
    // LOGICA PARA ATIVAR COMPRA 
    bool compra = close_atual > superior[0];
                          
    bool venda = close_atual < inferior[0] || open_atual < inferior[0];
   
    Comprar = compra;
    Vender  = venda;
 
    // retorna true se tivermos uma nova vela
    bool temosNovaVela = TemosNovaVela(); 
    // Toda vez que existir uma nova vela entrar nesse 'if'
    if(temosNovaVela)
      {
       
       // Condição de Compra:
       if(Comprar && PositionSelect(_Symbol)==false && pode_operar)
         {
          desenhaLinhaVertical("Compra",velas[1].time,clrBlue);
          CompraAMercado();
         }
       

       if(Vender && PositionSelect(_Symbol) && pode_operar) 
         {
          desenhaLinhaVertical("Venda",velas[1].time,clrRed);

//--------------------------------------------------------------
          FecharPosicao(); 
//--------------------------------------------------------------
  
         } 

      }   
 
  }
//+------------------------------------------------------------------+
//| Realizar compra com parâmetros especificados por input           |
//+------------------------------------------------------------------+
void CompraAMercado()
   {
   
    trade.Buy(Volume,_Symbol,NormalizeDouble(tick.ask,_Digits),_Digits);
      
      if(trade.ResultRetcode() == 10008 || trade.ResultRetcode() == 10009)
        {
            Print("Ordem de compra Executada com Sucesso!!");
        }else
           {
            Print("Erro de execução... ", GetLastError());
            ResetLastError();
           }          
     
   }
//---
void VendaAMercado()
   {
   
      if(trade.ResultRetcode() == 10008 || trade.ResultRetcode() == 10009)
        {
            Print("Ordem de venda Executada com Sucesso!!");
        }else
           {
            Print("Erro de execução... ", GetLastError());
            ResetLastError();
           }              
   
   }
//+------------------------------------------------------------------+
void FecharPosicao()
   {
   
      ulong ticket = PositionGetTicket(0);
      
      trade.PositionClose(ticket);
      
      if(trade.ResultRetcode() == 10009)
        {
            Print("Fechamento Executado com Sucesso!!");
        }else
           {
            Print("Erro de execução... ", GetLastError());
            ResetLastError();
           }  
   
   }
   
// ----------

//--- Para Mudança de Candle
bool TemosNovaVela()
  {
//--- memoriza o tempo de abertura da ultima barra (vela) numa variável
   static datetime last_time=0;
//--- tempo atual
   datetime lastbar_time= (datetime) SeriesInfoInteger(Symbol(),Period(),SERIES_LASTBAR_DATE);

//--- se for a primeira chamada da função:
   if(last_time==0)
     {
      //--- atribuir valor temporal e sair
      last_time=lastbar_time;
      return(false);
     }

//--- se o tempo estiver diferente:
   if(last_time!=lastbar_time)
     {
      //--- memorizar esse tempo e retornar true
      last_time=lastbar_time;
      return(true);
     }
//--- se passarmos desta linha, então a barra não é nova; retornar false
   return(false);
  }
//---

void desenhaLinhaVertical(string nome, datetime dt, color cor = clrAliceBlue)
   {
      ObjectDelete(0,nome);
      ObjectCreate(0,nome,OBJ_VLINE,0,dt,0);
      ObjectSetInteger(0,nome,OBJPROP_COLOR,cor);
   } 
   
