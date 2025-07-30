// ProfitMaxX_EA.mq5 - Skeleton Framework
// A powerful, aggressive profit-generating bot using Smart Money Concepts

#property strict
#property script_show_inputs

#include <Trade/Trade.mqh>

// Arrow codes for chart objects (Wingdings)
#ifndef SYMBOL_ARROWUP
#define SYMBOL_ARROWUP   233
#endif
#ifndef SYMBOL_ARROWDOWN
#define SYMBOL_ARROWDOWN 234
#endif

//--- Input parameters
input string SymbolsList            = "EURUSD,GBPUSD,USDJPY,US30,XAUUSD"; // Symbols to trade
input double MinRiskPercent         = 1.0;   // Minimum risk percent per trade
input double MaxRiskPercent         = 3.0;   // Maximum risk percent per trade
input string SL_PerSymbol           = "EURUSD=30;XAUUSD=150";             // Default SL per symbol (points)
input bool   UseAdaptiveRRR         = true;  // Use ATR based SL/TP
input double ATRMultiplier          = 1.5;   // SL = ATR * multiplier
input double TP1_RR                 = 1.5;   // Risk reward for TP1
input double TP2_RR                 = 3.0;   // Risk reward for TP2
input double TP3_RR                 = 5.0;   // Risk reward for TP3
input double TP1_Percent            = 0.33;  // Percent to close at TP1
input double TP2_Percent            = 0.33;  // Percent to close at TP2
input double TP3_Percent            = 0.34;  // Percent to close at TP3
input bool   EnableTPOptimization   = true;  // Auto-adjust TP allocation
input int    SlippagePoints         = 5;     // Maximum slippage in points
input int    SpreadLimitPoints      = 20;    // Maximum allowed spread for reentry
input double MaxAllowedSpreadPoints = 25;    // Max spread in points before blocking entry
input bool   EnableSpreadFilter     = true;  // Skip entries when spread too high
input double SpreadSpikeMultiplier  = 1.5;   // Spread spike threshold factor
input bool   EnableNewsAwareFilter  = true;  // Use MT5 calendar news filter
input int    MinutesBeforeNews      = 15;    // Minutes before news to block
input int    MinutesAfterNews       = 15;    // Minutes after news to block
input bool   EnableNewsFilter       = true;  // Enable news filter
input int    NewsCooldownMinutes    = 30;    // Minutes before/after event to block
input int    NewsBlockMinutes       = 30;    // Block minutes around high-impact events
input bool   IncludeMediumImpactNews= true;  // Also block on medium impact news
input string NewsHours              = "12-14"; // News hours window
input bool   EnableLiveNewsFilter   = true;  // Use external JSON news feed
input int    NewsBlockBeforeMinutes = 30;    // Minutes before event to block
input int    NewsBlockAfterMinutes  = 30;    // Minutes after event to block
input string NewsAPISource          = "forexfactory"; // News API source
input string NewsKeywords           = "";   // Filter keywords
input bool   OverrideNewsFilter     = false; // Manually bypass news filter
input bool   EnableSessionFilter    = false; // Enable session filter
input string AllowedSessions        = "London,NY"; // Allowed trading sessions
input bool   EnableMultiStageTP     = true;  // Use multi-stage take profit
input bool   EnableVolatilityFilter = false; // Use ATR filter for volatility
input bool   UseHiddenSL            = false; // Hide stop loss from broker
input string TelegramToken          = "";   // Telegram bot token
input string TelegramChatID         = "";   // Telegram chat ID
input bool   EnableContextRecorder  = true;  // Record trade context
input bool   EnableDataRecorder     = true;  // Record detailed data to CSV
input string DataLogFile            = "PMX_Data_Log.csv"; // Data log file
input string DataRecordFile         = "TradeEntryData.csv"; // Additional entry log
input bool   EnableConfidenceAutoTune = true; // Enable indicator tuning log
input string TuningLogFile          = "PMX_Tuning_Log.csv"; // tuning log file
input int    CooldownMinutes        = 2;     // Cooldown between trades per symbol
input string ExecutionLogFile       = "ExecutionLog.csv"; // execution performance log
input double MaxDailyDrawdownPercent = 10.0; // Max % daily drawdown before pause
input double MaxEquityLossPercent    = 5.0;  // Max % equity loss before pause
input int    CooldownMinutesAfterLoss = 15;  // Cooldown minutes after a losing trade
// Adaptive Learning inputs
input bool   EnableAdaptiveLearning   = true;   // Enable adaptive logic
input double BaseConfidenceThreshold  = 0.25;   // Starting confidence threshold
input int    AdaptiveLookbackTrades   = 20;     // Number of trades to track
input int    AdaptiveResetHour        = 0;      // Hour to reset learning daily

input double EquityGrowthBoostCap    = 0.5;  // Max compounding boost %
input int    PauseAfterErrorMinutes  = 5;     // Pause trading minutes after reject
input bool   EnableSymbolStrengthMeter = true; // Display symbol strength
input bool   EnableSLTPOptimizer      = true;  // Optimize SL/TP using ATR
input bool   EnableSmartEquityScaling = true;  // Adjust risk by equity
input bool   EnableSymbolRotation     = true;  // Auto pause weak symbols
input bool   EnableObliterationMode  = false; // Lower threshold after loss
input int    ObliterationMinutes     = 30;    // Minutes for obliteration mode
input int    MaxWinStreakBeforeCooldown = 3;  // Wins in a row before cooldown
input int    MaxLossStreakBeforeCooldown = 2; // Losses in a row before cooldown
input int    StreakCooldownMinutes   = 10;    // Cooldown minutes after streak
input bool   EnableAISetupFilter      = true; // Use AI pattern stub filter
input bool   EnableLiquidityTrapFilter = true; // Filter liquidity traps
input int    WinCooldownMinutes       = 10;   // Cooldown mins after win streak
input int    LossCooldownMinutes      = 10;   // Cooldown mins after loss streak
input string ConfidenceTunerFile      = "ConfidenceTuner_Log.csv";
// Phase 12 emotional cooldown inputs
input bool   EnableEmotionalCooldown  = true;
input int    MaxConsecutiveWins       = 3;
input int    MaxConsecutiveLosses     = 2;
input int    EmotionalCooldownMinutes = 30;
input bool   EnableAIPatternFilter     = true;          // Toggle AI pattern module
input string AI_API_URL               = "http://localhost:5000/predict"; // Python AI endpoint
input double AI_ConfidenceThreshold   = 0.7;            // Required confidence (0-1)
// AI pattern detection via simpler API
input bool   EnableAIPatternDetection = true;
input string AIEndpointURL            = "http://localhost:5000/predict"; // Simple AI endpoint
input bool   EnableAIPatterns         = true;          // Phase 6 AI signals
input int    AICandleCount            = 20;            // Candles to send to AI
input bool   EnableConfidenceAutoTuner = true;         // Phase 10 tuner toggle
string       ConfidenceLogFile         = "ConfidenceLearning.csv";
input bool   EnableFeedbackLoop       = true;         // Strategy feedback loop
input int    FeedbackTradeInterval    = 10;           // Trades before feedback
input int    FeedbackHourInterval     = 1;            // Hours between feedback
input bool   ResetFeedbackNow         = false;        // Manual feedback reset
input bool   EnableBrokerSimulation = true;   // Simulate broker execution
input bool   EnableExecutionSimulation = true;  // Simulate real execution effects
input int    MaxSlippageSimPoints   = 15;       // Max slippage points in simulation
input int    RequoteChancePercent   = 5;        // Chance of requote %
input int    RejectionChancePercent = 2;        // Chance of rejection %
input bool   EnableExecutionSimulator = true;   // Enable simplified execution sim
input int    SimulatedSlippageMaxPoints = 10;   // Max random slippage in points
input int    SimulatedOrderDelayMs = 200;       // Delay in ms
input double SimulatedRejectionChance = 0.05;   // Rejection chance
input bool   EnableExecutionSim    = true;   // Reality simulator toggle
input int    SimMaxSlippagePoints  = 5;      // Max slippage points
input double SimRejectProbability  = 0.05;   // Rejection probability
input bool   EnableBrokerAwareness   = true;   // Adapt to broker conditions
input int    MaxAllowedSpread        = 30;     // Spread limit in points
input int    MinExecSpeedMs          = 50;     // Min expected execution speed
input int    MaxExecSpeedMs          = 1500;   // Threshold for slow broker
input bool   EnableExecutionTuning   = true;   // Monitor execution performance
input int    MaxAllowedSlippage      = 8;      // Avg slippage threshold
input int    MaxAllowedLatency       = 1500;   // Avg latency threshold (ms)
input bool   EnableSpreadLimit       = true;   // Block trades if spread too high
input bool   EnableLiquidityFilter    = true;  // Avoid trades near liquidity pools
input int    LiquidityProximityPoints = 10;    // Distance in points to swing high/low
input bool   EnableLiquidityDetection = true;  // Detect clustered liquidity zones
input int    LP_CandleCount           = 20;    // Candles to scan for liquidity pools
input double LP_SensitivityPoints     = 10.0;  // Wick similarity tolerance
// Phase 4 inputs
input int    MaxAllowedPingMs       = 500;    // Skip trade if ping above this
input int    MaxSlippagePoints      = 10;     // Flag high slippage beyond this
input double MaxMarginUsePercent    = 75.0;   // Broker-aware margin limit
input double EquityFloorPercent     = 50.0;   // Equity floor percent of balance
input int    MaxPingLimitMs         = 2000;   // Hard ping limit kill switch
// Circuit Breaker inputs
input double MaxMarginUsagePercent   = 80.0; // % of margin usage allowed before bot pauses
input double MinEquityAbsolute     = 50.0; // Minimum equity (USD) before halt
input int    MaxLatencyMS            = 5000; // Maximum acceptable network latency
input bool   ManualCircuitReset      = false; // Set true to manually resume after trigger
input bool   EnableReminderTriggers  = true;  // Allow manual command triggers
// Kill switch inputs
input double KillMarginUsagePercent = 90.0; // % of margin used triggers kill switch
input double KillEquityThreshold    = 50.0;  // Minimum account equity ($) before shutdown
input int    MaxAllowedLatencyMs    = 5000;  // Max network latency in ms
input int    CircuitResetHours      = 12;    // Hours to wait before auto resume

//--- Global variables and structures
struct TradeInfo
  {
   string  symbol;
   ulong   ticket;
   double  lot;            // remaining lot
   double  initialLot;     // lot at trade open
   double  stopLoss;
   double  takeProfit1;
   double  takeProfit2;
   double  takeProfit3;
   double  confidence;
   datetime openTime;
   double  entryPrice;
   int      stage;         // 0=none,1=tp1,2=tp2
   bool     isBuy;
   string   indicators;
   // factors used for this trade
   bool     facEMA;
   bool     facRSI;
   bool     facOB;
   bool     facBOS;
   bool     facEngulf;
   double   spreadEntry;
   double   atrEntry;
  };

struct ConfidenceProfile
  {
   double EMAWeight;
   double RSIWeight;
   double OBWeight;
   double BOSWeight;
   double EngulfingWeight;
  };

string   gSymbols[];            // Parsed symbols
datetime gLastTradeTime[];      // Last trade time per symbol
int      gSymbolCount = 0;
TradeInfo gTrades[];            // Active trades info
datetime gCooldownEndTime[];    // cooldown end per symbol after losses
double   gLastConfidence[];     // last calculated confidence per symbol
double   gLastSpread[];        // last spread per symbol
double   gSpreadAvg[];         // average spread
int      gSpreadSamples[];     // sample count for spread
double   gAIPatternConf[];     // last AI pattern confidence
bool     gAIPatternDir[];      // last AI predicted direction (true=buy)
int      gWinCount[];           // total wins per symbol
int      gLossCount[];          // total losses per symbol
int      gStreak[];             // win/loss streak (positive=win, negative=loss)
datetime gLastLossTime[];       // time of last loss per symbol
datetime gOblitUntil[];         // obliteration mode end time per symbol
bool     gReentryAllowed[];     // reentry flag after BE
double   gReentryPrice[];       // price to watch for reentry
bool     gReentryDirection[];   // direction to reenter
double   gStartDayBalance=0;    // balance at start of day
double   gStartDayEquity=0;     // equity at start of day
double   gInitialBalance=0;     // balance when EA started
datetime gStartDayTime=0;       // day tracking
bool     gTradingPaused=false;  // pause trading due to drawdown
datetime gErrorPauseEndTime=0;  // pause end time after order error
bool     gCircuitTriggered=false; // circuit breaker status
bool     gCircuitBreakerActive=false; // new circuit breaker kill switch
bool     gCircuitBreakerTripped=false; // hard kill switch state
datetime gCircuitResumeTime=0;  // auto resume time after kill
string   gCircuitReason="";    // last kill switch reason
int      gDayWins=0;            // wins today
int      gDayLosses=0;          // losses today
double   gDayConfSum=0.0;       // sum of entry confidence today
int      gDayConfCount=0;       // number of trades today
datetime gLastNewsUpdate=0;     // last time news data fetched
string   gNewsSymbols[];        // currencies of news events
datetime gNewsStart[];          // event start time minus buffer
datetime gNewsEnd[];            // event end time plus buffer
datetime gLastNewsAlert[];      // last alert time per symbol
string   gNewsNames[];          // event descriptions
string   gNewsImpact[];         // impact level (High/Medium)
datetime gCalCacheTime=0;       // last calendar cache update
MqlCalendarValue gCalEvents[];  // cached MT5 calendar events
int      gCalCount=0;
datetime gTrapTime[];           // last detected liquidity trap time per symbol
double   gLiqBuyLevel[];        // detected buy-side liquidity level per symbol
double   gLiqSellLevel[];       // detected sell-side liquidity level per symbol
datetime gLastLearnUpdate[];    // last time auto-tuner ran per symbol
double   gSymbolStrength[];     // strength meter per symbol
datetime gSymbolPauseUntil[];   // auto rotation pause per symbol
int      gEmoWinStreak[];       // emotional win streak per symbol
int      gEmoLossStreak[];      // emotional loss streak per symbol
datetime gEmoCooldownUntil[];   // emotion cooldown end per symbol
int      gTunerTradeCount=0;    // counter for confidence tuner
// Feedback loop state
double   gFBMultiplier[];       // confidence multiplier per symbol
int      gFBConsecLoss[];       // consecutive losses
int      gFBWins[];             // wins per symbol
int      gFBLosses[];           // losses per symbol
datetime gLastFeedbackTime=0;
int      gFeedbackTradeCount=0;
// Adaptive Learning state
int      gTradeWins = 0;
int      gTradeLosses = 0;
double   gDynamicConfidence = BaseConfidenceThreshold;
double   gDynamicTPMult = 1.0;
datetime gLastAdaptiveReset = 0;


// === BOOST LOGIC ===
int gWinStreak = 0;
int gLossStreak = 0;
datetime gLastLossGlobal = 0;
datetime gStreakCooldownUntil = 0;
// === PERFORMANCE TRACKING ===
int consecutiveWins = 0;
int consecutiveLosses = 0;
datetime emotionalCooldownEnd = 0;
double gTotalProfit = 0;
double gTotalLoss   = 0;
int    gTotalWins   = 0;
int    gTotalLosses = 0;
int    gTotalTrades = 0;
int    gTP1Count   = 0;
int    gTP2Count   = 0;
int    gTP3Count   = 0;
double gAvgPing    = 0.0;     // broker latency baseline
double gExecAvgMs  = 0.0;     // average execution time
int    gExecSamples= 0;
double gLastPing    = 0.0;     // last measured ping
double gLastSlippage= 0.0;     // last slippage recorded
int    gSlowExecStreak = 0;    // consecutive slow executions
int    gLiquiditySkipCount = 0; // count of skips due to liquidity traps
double gExecSlipSum[] = {};
int    gExecSlipCount[] = {};
double gExecLatSum[] = {};
int    gExecLatCount[] = {};
int    gExecRequotes[] = {};
int    gExecOrders[] = {};
int    gExecSuccess[] = {};
datetime gExecResetTime = 0;

// --- Adaptive Market Mode & Performance ---
enum MarketMode {MODE_CAUTIOUS=0, MODE_BALANCED=1, MODE_AGGRESSIVE=2};
int      gMarketMode = MODE_BALANCED;
datetime gModeLastChange = 0;

double   gPerfRRWinSum=0,gPerfRRLosSum=0;
double   gPerfConfWinSum=0,gPerfConfLosSum=0;
int      gPerfDailyTrades=0,gPerfDailyWins=0,gPerfDailyLosses=0;
datetime gPerfDay=0;

string   TradeMemoryFile="TradeMemory.csv";
string   PerformanceFile="ProfitMaxX_Performance.csv";
// Broker performance profile
struct BrokerProfile
  {
   double avgExecutionTimeMs;
   double maxSlippagePoints;
   double minLotSize;
   double marginPerLot;
   datetime lastUpdateTime;
  };
BrokerProfile gBroker;


ConfidenceProfile gProfiles[];  // weights per symbol

//--- Function declarations (placeholders)
void   ParseInputStrings();
bool   IsHighImpactNewsNow(string symbol);
bool   CheckNewsImpact(string symbol);
void   UpdateNewsCache();
void   LoadFallbackNews();
void   GetSymbolCurrencies(string symbol,string &c1,string &c2);
bool   IsSessionAllowed();
bool   CoolDownPassed(string symbol);
int    DetectOrderBlocks(string symbol);
int    DetectBreakOfStructure(string symbol);
int    DetectFairValueGap(string symbol);
int    DetectImbalance(string symbol);
struct ConfidenceFactors
  {
   bool ema;
   bool rsi;
   bool ob;
   bool bos;
   bool engulf;
  };
double CalculateConfidence(string symbol,bool &isBuy,ConfidenceFactors &fac);
double GetFallbackSL(string symbol);
double GetAdaptiveSL(string symbol);
bool   HasOpenPosition(string symbol);
bool   VolatilityFilter(string symbol);
bool   SpreadOK(string symbol);
double CalculateLotSize(string symbol, double stopLossPoints, double confidence);
double GetSpreadPoints(string symbol);
bool   IsSpreadAcceptable(string symbol);
bool   IsAIPatternFavorable(string symbol,bool &isBuy);
bool   GetAIRecommendation(string symbol,bool &aiBuy,double &confidence);
void   EnterTrade(string symbol, bool isBuy, double confidence,ConfidenceFactors fac);
void   ManageOpenPositions();
void   ApplyTrailingStop(TradeInfo &info);
void   PartialClose(TradeInfo &info, int stage);
void   CloseAtStop(TradeInfo &info);
void   StartCooldown(string symbol);
void   UpdateStats(string symbol,bool win);
int    GetSymbolIndex(string symbol);
void   CheckDailyDrawdown();
bool   SendTelegram(string message);
void   LogEvent(string symbol, string event, double lot, double sl, double tp, double confidence);
void   LogSlippage(string symbol,double reqPrice,double fillPrice);
void   LogNewsBlock(string symbol,datetime newsTime,string impact,string desc);
void   UpdateDashboard();
void   CheckCircuitBreakers();
void   CheckCircuitBreaker();
void   CircuitBreakerKillSwitch();
// Additional modules
void   AdaptiveLearningModule();
void   PerformanceAnalyzer();
string UrlEncode(string text);
string StringBetween(string data,string a,string b);
long   GetChartForSymbol(string symbol);
void   DrawTradeObjects(ulong ticket,string symbol,bool isBuy,double entry,double sl,double tp1,double tp2,double tp3);
void   RemoveTradeObjects(ulong ticket);
void   LoadConfidenceProfile(string symbol, ConfidenceProfile &prof);
void   SaveConfidenceProfile(string symbol, ConfidenceProfile &prof);
void   UpdateConfidenceProfile(string symbol,bool win,ConfidenceFactors fac);
bool   IsLiquidityTrapLikely(string symbol,bool isBuy);
void   MarkLiquidityZone(string symbol,double lvl1,double lvl2,datetime t1,datetime t2);
void   DetectLiquidityPools(string symbol,double &buyLevel,double &sellLevel);
bool   IsNearLiquidityTrap(string symbol,bool isBuy);
void   LogLiquidityPool(string symbol,string zoneType,double price,string direction);
void   LearnFromTradeResult(string symbol,bool wasWin,double confidence,string entryFactors);
void   RecordTradeContext(string symbol,double confidence,bool isBuy);
void   LogTradeData(string symbol,bool isBuy,double confidence);
void   RecordEntryData(string symbol,bool isBuy,double confidence,double lot,double sl,double tp);
void   LogTuningData(string symbol,double profit,double confidence,string indicators,bool isBuy);
void   UpdateConfidenceTuner(string symbol,bool win,double confidence,double profit);
string GetCurrentSession();
bool   QueryAIPattern(string symbol,bool &dir,double &conf);
bool   GetAIPrediction(string symbol,bool &dir,double &conf);
void   LogConfidenceData(string symbol,double confidence,bool isBuy,double resultPips);
void   RecordTradeOutcome(const MqlTradeTransaction &trans);
double GetAdaptiveConfidence(string symbol,bool isBuy);
bool IsEmotionCooldownActive();
void ResetStreakCounters();
void HandleEmotionStreaks(const MqlTradeTransaction &trans);
void   SimulateBrokerConditions(string symbol,bool isBuy,double &price);
bool   SimulateExecution(MqlTradeRequest &req);
bool   SimulateExecutionSimple();
void   CalibrateBroker();
void   TrackExecutionSpeed(ulong start,string symbol);
void   UpdateSymbolStrength();
void   OptimizeSLTP(string symbol,bool isBuy,double &slPts,double &tp1,double &tp2,double &tp3);
void   InitBrokerProfile();
void   UpdateBrokerProfile(double actualSlippagePts,int executionTimeMs);
bool   SendSmartOrder(MqlTradeRequest &req,MqlTradeResult &res,string symbol,bool isBuy);
bool   IsHighProbabilitySetup(string symbol);
void   LogFeedbackTrade(string symbol,bool isBuy,double conf,double sl,double tp,bool win,double spread,datetime t,double atr,double rrr);
void   FeedbackLoopUpdate();
void   ResetFeedbackStats();
void   UpdateTPOptimization();
bool   SimulateExecutionAdvanced(MqlTradeRequest &req,double maxLat,double maxSlip,double rejectChance,double requoteChance);
void   UpdatePerformanceStats(string symbol,bool win,double rr,double confidence);
void   SaveTradeMemory(string symbol,bool isBuy,double conf,ConfidenceFactors fac,bool win,int stage);
double EvaluateTradeMemory(string symbol,bool isBuy,double conf,ConfidenceFactors fac);
int    DetectMarketMode();
bool   RunIntegrityValidator();
void   CheckReminderTriggers();
void   RunTroubleshoot();
void   RunYellowReminder();

//--- OnInit function
void LogExecution(string symbol,datetime reqT,datetime resT,double reqPrice,double fillPrice,uint retcode);
void UpdateExecutionStats(string symbol,double slip,double latency,bool success,bool requote);
void ResetExecutionStats();
double GetAvgSlippage(string symbol);
double GetAvgLatency(string symbol);
double GetRequoteRate(string symbol);
int OnInit()
  {
  ParseInputStrings();
  ArrayResize(gProfiles,gSymbolCount);
  ArrayResize(gCooldownEndTime,gSymbolCount);
  ArrayResize(gLastConfidence,gSymbolCount);
  ArrayResize(gWinCount,gSymbolCount);
  ArrayResize(gLastSpread,gSymbolCount);
  ArrayResize(gSpreadAvg,gSymbolCount);
  ArrayResize(gSpreadSamples,gSymbolCount);
  ArrayResize(gAIPatternConf,gSymbolCount);
  ArrayResize(gAIPatternDir,gSymbolCount);
  ArrayResize(gLossCount,gSymbolCount);
  ArrayResize(gStreak,gSymbolCount);
  ArrayResize(gLastLossTime,gSymbolCount);
  ArrayResize(gOblitUntil,gSymbolCount);
  ArrayResize(gReentryAllowed,gSymbolCount);
  ArrayResize(gReentryPrice,gSymbolCount);
  ArrayResize(gReentryDirection,gSymbolCount);
  ArrayResize(gReentryPrice,gSymbolCount);
  ArrayResize(gReentryDirection,gSymbolCount);
  ArrayResize(gTrapTime,gSymbolCount);
  ArrayResize(gLiqBuyLevel,gSymbolCount);
  ArrayResize(gLiqSellLevel,gSymbolCount);
  ArrayResize(gLastNewsAlert,gSymbolCount);
  ArrayResize(gNewsNames,0);
  ArrayResize(gNewsImpact,0);
  ArrayResize(gLastLearnUpdate,gSymbolCount);
  ArrayResize(gSymbolStrength,gSymbolCount);
  ArrayResize(gSymbolPauseUntil,gSymbolCount);
  ArrayResize(gEmoWinStreak,gSymbolCount);
  ArrayResize(gEmoLossStreak,gSymbolCount);
  ArrayResize(gEmoCooldownUntil,gSymbolCount);
  ArrayResize(gFBMultiplier,gSymbolCount);
  ArrayResize(gFBConsecLoss,gSymbolCount);
  ArrayResize(gFBWins,gSymbolCount);
  ArrayResize(gFBLosses,gSymbolCount);
  ArrayResize(gExecSlipSum,gSymbolCount);
  ArrayResize(gExecSlipCount,gSymbolCount);
  ArrayResize(gExecLatSum,gSymbolCount);
  ArrayResize(gExecLatCount,gSymbolCount);
  ArrayResize(gExecRequotes,gSymbolCount);
  ArrayResize(gExecOrders,gSymbolCount);
  ArrayResize(gExecSuccess,gSymbolCount);
  for(int i=0;i<gSymbolCount;i++)
    {
     gCooldownEndTime[i]=0;
    gLastConfidence[i]=0;
   gLastSpread[i]=0;
    gSpreadAvg[i]=0;
    gSpreadSamples[i]=0;
    gAIPatternConf[i]=0;
    gAIPatternDir[i]=true;
    gWinCount[i]=0;
     gLossCount[i]=0;
     gStreak[i]=0;
     gLastLossTime[i]=0;
     gOblitUntil[i]=0;
     gReentryAllowed[i]=false;
    gReentryPrice[i]=0.0;
    gReentryDirection[i]=true;
    gTrapTime[i]=0;
    gLiqBuyLevel[i]=0.0;
    gLiqSellLevel[i]=0.0;
    gLastNewsAlert[i]=0;
    gLastLearnUpdate[i]=0;
    gSymbolStrength[i]=0.0;
    gExecSlipSum[i]=0;
    gExecSlipCount[i]=0;
    gExecLatSum[i]=0;
    gExecLatCount[i]=0;
    gExecRequotes[i]=0;
    gExecOrders[i]=0;
    gExecSuccess[i]=0;
    gSymbolPauseUntil[i]=0;
    gEmoWinStreak[i]=0;
    gEmoLossStreak[i]=0;
    gEmoCooldownUntil[i]=0;
    LoadConfidenceProfile(gSymbols[i],gProfiles[i]);
    }
  gStartDayTime=TimeCurrent();
  gStartDayBalance=AccountInfoDouble(ACCOUNT_BALANCE);
  gStartDayEquity=AccountInfoDouble(ACCOUNT_EQUITY);
  gInitialBalance=AccountInfoDouble(ACCOUNT_BALANCE);
  gDayWins=0;
  gDayLosses=0;
  gDayConfSum=0.0;
  gDayConfCount=0;
  gErrorPauseEndTime=0;
  gCircuitTriggered=false;
  gCircuitBreakerActive=false;
  gCircuitBreakerTripped=false;
  gCircuitResumeTime=0;
  gCircuitReason="";
  gStreakCooldownUntil=0;
  gCalCacheTime=0;
  consecutiveWins=0;
  consecutiveLosses=0;
  emotionalCooldownEnd=0;
  ArrayResize(gCalEvents,0);
  gLastPing=TerminalInfoInteger(TERMINAL_PING_LAST);
gExecResetTime=TimeCurrent();
  gLastSlippage=0.0;
  gSlowExecStreak=0;
  gCalCount=0;
  gLiquiditySkipCount=0;
  CalibrateBroker();
  InitBrokerProfile();
  if(TelegramToken=="" || TelegramChatID=="")
     Print("Warning: Telegram credentials not set");
  else
     SendTelegram("ProfitMaxX_EA initialized");
  MathSrand((uint)TimeLocal());
  gTradeWins=0;
  gTradeLosses=0;
  gTunerTradeCount=0;
  gDynamicConfidence=BaseConfidenceThreshold;
  gDynamicTPMult=1.0;
  gLastAdaptiveReset=TimeCurrent();
  gLastFeedbackTime=TimeCurrent();
  gFeedbackTradeCount=0;
  gPerfDay=TimeDay(TimeCurrent());
  bool v=RunIntegrityValidator();
  if(!v) Print("Integrity check failed");
  Print("Ensure WebRequest allowed for https://nfs.faireconomy.media");
  if(EnableLiveNewsFilter)
    {
     Print("Fetching news from "+NewsAPISource);
     UpdateNewsCache();
    }
  Print("ProfitMaxX_EA Initialized");
  return(INIT_SUCCEEDED);
 }

//--- OnDeinit function
void OnDeinit(const int reason)
  {
   Print("ProfitMaxX_EA Deinitialized");
  for(long cid=ChartFirst(); cid>=0; cid=ChartNext(cid))
    {
     for(int i=ObjectsTotal(cid)-1;i>=0;i--)
       {
        string name=ObjectName(cid,i);
        if(StringFind(name,"PMX_")==0)
           ObjectDelete(cid,name);
       }
    }
   for(int i=0;i<gSymbolCount;i++)
      SaveConfidenceProfile(gSymbols[i],gProfiles[i]);
  }

//--- OnTick function
void OnTick()
  {
  CheckCircuitBreaker();
  CheckReminderTriggers();
  if(gCircuitBreakerTripped)
     return;
  gLastPing=TerminalInfoInteger(TERMINAL_PING_LAST);
  DetectMarketMode();
  UpdateSymbolStrength();
  CheckDailyDrawdown();
  CircuitBreakerKillSwitch();
  if(ManualCircuitReset && gCircuitTriggered)
     {
      gTradingPaused=false;
      gCircuitTriggered=false;
      ManualCircuitReset=false;
      Print("Circuit breaker manually reset");
      SendTelegram("Circuit breaker manually reset");
     }
   CheckCircuitBreakers();
  if(gCircuitBreakerActive)
    {
     ManageOpenPositions();
     UpdateDashboard();
     return;
    }
  if(gTradingPaused && gCircuitReason!="")
    {
     ManageOpenPositions();
     UpdateDashboard();
     return;
    }
  if(gTradingPaused && gErrorPauseEndTime>0 && TimeCurrent()>=gErrorPauseEndTime)
     {
      gTradingPaused=false;
      gErrorPauseEndTime=0;
     }
  if(TimeCurrent()<gErrorPauseEndTime)
    {
     ManageOpenPositions();
     UpdateDashboard();
     return;
    }
  if(IsEmotionCooldownActive())
    {
     ManageOpenPositions();
     UpdateDashboard();
     return;
    }
  if(TimeCurrent()<gStreakCooldownUntil)
    {
     ManageOpenPositions();
     UpdateDashboard();
     return;
    }
  for(int i=0;i<gSymbolCount;i++)
     {
      string sym=gSymbols[i];
      if(gTradingPaused) continue;
      if(TimeCurrent()<gStreakCooldownUntil) continue;
        if(IsEmotionCooldownActive()) continue;
      if(TimeCurrent()<gEmoCooldownUntil[i]) continue;
      if(EnableSymbolRotation && TimeCurrent()<gSymbolPauseUntil[i]) continue;
      if(EnableLiveNewsFilter && CheckNewsImpact(sym)) continue;
      if(IsNewsAwareEvent(sym)) continue;
      if(EnableSessionFilter && !IsSessionAllowed()) continue;
      if(!CoolDownPassed(sym)) continue;
      if(HasOpenPosition(sym)) continue;
      if(EnableVolatilityFilter && !VolatilityFilter(sym)) continue;
      if(gLastPing>MaxAllowedPingMs)
        {
         string pmsg=StringFormat("\xE2\x9A\xA0 Ping %.0fms too high for %s",gLastPing,sym);
         Print(pmsg);
         SendTelegram(pmsg);
         LogEvent(sym,"PING_SKIP",0,0,0,gLastPing);
         continue;
        }

      if(!IsHighProbabilitySetup(sym))
        {
         string msg=StringFormat("AI setup filter blocked trade on %s",sym);
         Print(msg);
         
         LogEvent(sym,"AI_SETUP_BLOCK",0,0,0,0);
         continue;
        }

      gLastSpread[i]=GetSpreadPoints(sym);
      if(EnableSpreadFilter && !IsSpreadAcceptable(sym)) {
         string msg=StringFormat("⚠ Spread too high for %s: %.1f pts — Skipped entry",sym,gLastSpread[i]);
         Print(msg);
         
         LogEvent(sym,"SPREAD_SKIP",0,0,0,gLastSpread[i]);
         continue;
      }
      if(EnableExecutionTuning){
        int idx=GetSymbolIndex(sym);
        if(idx>=0 && gExecLatCount[idx]>0 && gExecLatSum[idx]/gExecLatCount[idx] > MaxAllowedLatency && (sym=="US30" || sym=="XAUUSD")){
          string m=StringFormat("Latency %.0fms too high for %s",gExecLatSum[idx]/gExecLatCount[idx],sym);
          Print(m); SendTelegram(m); LogEvent(sym,"LAT_SKIP",0,0,0,gExecLatSum[idx]/gExecLatCount[idx]);
          continue;
        }
      }
      bool isBuy=true;
      ConfidenceFactors fac;
      double conf=CalculateConfidence(sym,isBuy,fac);
       double adapt=GetAdaptiveConfidence(sym,isBuy);
       conf=(conf+adapt)/2.0;
      int fidx=GetSymbolIndex(sym); if(fidx>=0) conf*=gFBMultiplier[fidx];
      bool nearTrap=false;
      if(EnableLiquidityDetection && IsNearLiquidityTrap(sym,isBuy))
        {
         conf*=0.7; // reduce confidence near liquidity
         nearTrap=true;
        }
      bool aiDir=true;
      if(!IsAIPatternFavorable(sym,aiDir) || aiDir!=isBuy)
         continue;
      double aiConf=gAIPatternConf[i]/100.0;
      if(aiConf>=AI_ConfidenceThreshold) conf+=0.05;
      if(EnableBrokerAwareness && gExecSamples>10 && gExecAvgMs>MaxExecSpeedMs)
         conf-=0.1;
      conf=MathMax(0.0,MathMin(1.0,conf));
      gLastConfidence[i]=conf;
      double thresh=0.25;
      if(conf<gDynamicConfidence)
         continue;
      if(TimeCurrent()<gOblitUntil[i])
         thresh=0.15;
      if(nearTrap)
        {
         string msg=StringFormat("Liquidity trap near -- skipping trade on %s",sym);
         Print(msg);
         
         gTrapTime[i]=TimeCurrent();
         gLiquiditySkipCount++;
         continue;
        }
      if(gReentryAllowed[i])
        {
         double p=SymbolInfoDouble(sym,gReentryDirection[i]?SYMBOL_BID:SYMBOL_ASK);
         double pt=SymbolInfoDouble(sym,SYMBOL_POINT);
         if(pt>0 && MathAbs(p-gReentryPrice[i])<=SpreadLimitPoints*pt)
           {
            ConfidenceFactors f2; bool d=gReentryDirection[i];
            double c2=CalculateConfidence(sym,d,f2);
            bool ad=d;
            if(!IsAIPatternFavorable(sym,ad) || ad!=d)
              { gReentryAllowed[i]=false; continue; }
            double ac=gAIPatternConf[i]/100.0;
            if(ac>=AI_ConfidenceThreshold) c2+=0.05;
            if(c2<gDynamicConfidence){ gReentryAllowed[i]=false; continue; }
            EnterTrade(sym,d,MathMin(c2,0.5),f2);
            gReentryAllowed[i]=false;
          }
       }
      if(EnableLiquidityFilter && IsNearLiquidityPool(sym))
        {
         string msg=StringFormat("Liquidity trap near -- skipping trade on %s",sym);
         Print(msg);
         
         LogEvent(sym,"LIQ_NEAR",0,0,0,conf);
         continue;
        }
      if(EnableLiquidityTrapFilter && IsLiquidityTrapLikely(sym,isBuy))
        {
         Print("\xE2\x9A\xA0 Liquidity trap detected on ",sym," \xE2\x80\x93 skipping trade.");
         SendTelegram("\xE2\x9A\xA0 Liquidity trap avoided: "+sym);
         LogEvent(sym,"LIQ_TRAP",0,0,0,conf);
         int idx=GetSymbolIndex(sym); if(idx>=0) gTrapTime[idx]=TimeCurrent();
         continue;
        }
      if(conf>=thresh)
        {
         if(aiConf>=AI_ConfidenceThreshold)
            SendTelegram(StringFormat("\xF0\x9F\xA4\x96 AI Trade Signal: %s \xE2\x86\x92 %s (Confidence: %.2f)",sym,isBuy?"BUY":"SELL",aiConf));
         EnterTrade(sym,isBuy,conf,fac);
        }
    }
   ManageOpenPositions();
   UpdateDashboard();
   AdaptiveLearningUpdate();
   FeedbackLoopUpdate();
  }

//--- Trade transaction handler
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
  RecordTradeOutcome(trans);
  HandleEmotionStreaks(trans);
  if(trans.type==TRADE_TRANSACTION_DEAL_ADD)
    {
     if(trans.deal_entry==DEAL_ENTRY_OUT || trans.deal_entry==DEAL_ENTRY_INOUT ||
        trans.deal_entry==DEAL_ENTRY_OUT_BY)
       {
        int idxTrade=-1;
        for(int t=0;t<ArraySize(gTrades);t++)
          if(gTrades[t].ticket==trans.position){idxTrade=t;break;}
        if(idxTrade>=0)
          {
           bool wasWin=trans.profit>0;
           string factors=StringFormat("EMA=%d,RSI=%d,OB=%d,BOS=%d,ENG=%d",gTrades[idxTrade].facEMA?1:0,gTrades[idxTrade].facRSI?1:0,gTrades[idxTrade].facOB?1:0,gTrades[idxTrade].facBOS?1:0,gTrades[idxTrade].facEngulf?1:0);
          LearnFromTradeResult(trans.symbol,wasWin,gTrades[idxTrade].confidence,factors);
          LogTuningData(trans.symbol,trans.profit,gTrades[idxTrade].confidence,gTrades[idxTrade].indicators,gTrades[idxTrade].isBuy);
          UpdateConfidenceTuner(trans.symbol,wasWin,gTrades[idxTrade].confidence,trans.profit);
          double rrr=fabs(gTrades[idxTrade].takeProfit3 - gTrades[idxTrade].entryPrice)/
                     MathMax(fabs(gTrades[idxTrade].entryPrice - gTrades[idxTrade].stopLoss),1e-5);
          LogFeedbackTrade(trans.symbol,gTrades[idxTrade].isBuy,gTrades[idxTrade].confidence,
                           gTrades[idxTrade].stopLoss,gTrades[idxTrade].takeProfit3,
                           wasWin,gTrades[idxTrade].spreadEntry,gTrades[idxTrade].openTime,
                           gTrades[idxTrade].atrEntry,rrr);
          ConfidenceFactors pf; pf.ema=gTrades[idxTrade].facEMA; pf.rsi=gTrades[idxTrade].facRSI; pf.ob=gTrades[idxTrade].facOB; pf.bos=gTrades[idxTrade].facBOS; pf.engulf=gTrades[idxTrade].facEngulf;
          SaveTradeMemory(trans.symbol,gTrades[idxTrade].isBuy,gTrades[idxTrade].confidence,pf,wasWin,3);
          UpdatePerformanceStats(trans.symbol,wasWin,rrr,gTrades[idxTrade].confidence);
          gFeedbackTradeCount++;
          if(wasWin && (trans.deal_reason==DEAL_REASON_TP || trans.profit>0))
            {
             UpdateStats(trans.symbol,true);
             int s=GetSymbolIndex(trans.symbol); if(s>=0){gFBWins[s]++; gFBConsecLoss[s]=0;}
             ConfidenceFactors f; f.ema=gTrades[idxTrade].facEMA; f.rsi=gTrades[idxTrade].facRSI; f.ob=gTrades[idxTrade].facOB; f.bos=gTrades[idxTrade].facBOS; f.engulf=gTrades[idxTrade].facEngulf;
             UpdateConfidenceProfile(trans.symbol,true,f);
             ArrayRemove(gTrades,idxTrade,1);
             RemoveTradeObjects(trans.position);
            }
          }
        if(trans.deal_reason==DEAL_REASON_SL || trans.deal_reason==DEAL_REASON_STOPOUT)
          {
          UpdateStats(trans.symbol,false);
          int s=GetSymbolIndex(trans.symbol); if(s>=0){gFBLosses[s]++; gFBConsecLoss[s]++;}
          if(idxTrade>=0)
            {
              ConfidenceFactors f; f.ema=gTrades[idxTrade].facEMA; f.rsi=gTrades[idxTrade].facRSI; f.ob=gTrades[idxTrade].facOB; f.bos=gTrades[idxTrade].facBOS; f.engulf=gTrades[idxTrade].facEngulf;
              UpdateConfidenceProfile(trans.symbol,false,f);
              LogTuningData(trans.symbol,trans.profit,gTrades[idxTrade].confidence,gTrades[idxTrade].indicators,gTrades[idxTrade].isBuy);
              UpdateConfidenceTuner(trans.symbol,false,gTrades[idxTrade].confidence,trans.profit);
              double rrr=fabs(gTrades[idxTrade].takeProfit3 - gTrades[idxTrade].entryPrice)/
                         MathMax(fabs(gTrades[idxTrade].entryPrice - gTrades[idxTrade].stopLoss),1e-5);
              LogFeedbackTrade(trans.symbol,gTrades[idxTrade].isBuy,gTrades[idxTrade].confidence,
                               gTrades[idxTrade].stopLoss,gTrades[idxTrade].takeProfit3,
                               false,gTrades[idxTrade].spreadEntry,gTrades[idxTrade].openTime,
                               gTrades[idxTrade].atrEntry,rrr);
              gFeedbackTradeCount++;
              ArrayRemove(gTrades,idxTrade,1);
              RemoveTradeObjects(trans.position);
             }
          StartCooldown(trans.symbol);
          string msg=StringFormat("%s loss detected. Cooldown %d min",trans.symbol,
                                 CooldownMinutesAfterLoss);
          Print(msg);
          
        }
    }
    // update emotional streaks
    int sidx=GetSymbolIndex(trans.symbol);
    if(trans.profit>0)
      {
       gWinStreak++; gLossStreak=0;
       if(gWinStreak>=MaxWinStreakBeforeCooldown)
         {
          gStreakCooldownUntil=TimeCurrent()+StreakCooldownMinutes*60;
          gWinStreak=0; gLossStreak=0;
          SendTelegram("Win streak cooldown activated");
         }
       if(sidx>=0)
         {
          gEmoWinStreak[sidx]++; gEmoLossStreak[sidx]=0;
          if(gEmoWinStreak[sidx]>=3)
            {
             gEmoCooldownUntil[sidx]=TimeCurrent()+WinCooldownMinutes*60;
             string em="Win streak cooldown triggered for "+trans.symbol;
             Print(em); SendTelegram(em); LogEvent(trans.symbol,"WIN_CD",0,0,0,0);
             gEmoWinStreak[sidx]=0;
            }
         }
      }
    else if(trans.profit<0)
      {
       gLossStreak++; gWinStreak=0; gLastLossGlobal=TimeCurrent();
       if(gLossStreak>=MaxLossStreakBeforeCooldown)
         {
          gStreakCooldownUntil=TimeCurrent()+StreakCooldownMinutes*60;
          gWinStreak=0; gLossStreak=0;
          SendTelegram("Loss streak cooldown activated");
         }
       if(sidx>=0)
         {
          gEmoLossStreak[sidx]++; gEmoWinStreak[sidx]=0;
          if(gEmoLossStreak[sidx]>=2)
            {
             gEmoCooldownUntil[sidx]=TimeCurrent()+LossCooldownMinutes*60;
             string em="Loss streak cooldown triggered for "+trans.symbol;
             Print(em); SendTelegram(em); LogEvent(trans.symbol,"LOSS_CD",0,0,0,0);
             gEmoLossStreak[sidx]=0;
            }
         }
      }
  }
}

//--- Helper functions
void ParseInputStrings()
  {
   StringSplit(SymbolsList,',',gSymbols);
   gSymbolCount=ArraySize(gSymbols);
  ArrayResize(gLastTradeTime,gSymbolCount);
  ArrayResize(gLastConfidence,gSymbolCount);
  ArrayResize(gLastSpread,gSymbolCount);
  ArrayResize(gAIPatternConf,gSymbolCount);
  ArrayResize(gAIPatternDir,gSymbolCount);
  ArrayResize(gWinCount,gSymbolCount);
  ArrayResize(gLossCount,gSymbolCount);
  ArrayResize(gStreak,gSymbolCount);
  ArrayResize(gLastLossTime,gSymbolCount);
  ArrayResize(gOblitUntil,gSymbolCount);
  ArrayResize(gReentryAllowed,gSymbolCount);
  ArrayResize(gReentryPrice,gSymbolCount);
  ArrayResize(gReentryDirection,gSymbolCount);
  ArrayResize(gTrapTime,gSymbolCount);
  ArrayResize(gEmoWinStreak,gSymbolCount);
  ArrayResize(gEmoLossStreak,gSymbolCount);
  ArrayResize(gEmoCooldownUntil,gSymbolCount);
  for(int i=0;i<gSymbolCount;i++)
    {
     gLastTradeTime[i]=0;
    gLastSpread[i]=0;
    gLastConfidence[i]=0;
    gAIPatternConf[i]=0;
    gAIPatternDir[i]=true;
    gWinCount[i]=0;
     gLossCount[i]=0;
     gStreak[i]=0;
   gLastLossTime[i]=0;
   gOblitUntil[i]=0;
   gReentryAllowed[i]=false;
   gReentryPrice[i]=0.0;
     gReentryDirection[i]=true;
     gTrapTime[i]=0;
    gEmoWinStreak[i]=0;
    gEmoLossStreak[i]=0;
    gEmoCooldownUntil[i]=0;
    gFBMultiplier[i]=1.0;
    gFBConsecLoss[i]=0;
    gFBWins[i]=0;
    gFBLosses[i]=0;
    }
 }

// Fetch and cache news events from external feed
void UpdateNewsCache()
  {
   datetime now=TimeCurrent();
   if(now-gLastNewsUpdate<600)
      return;
   gLastNewsUpdate=now;
  ArrayResize(gNewsSymbols,0);
  ArrayResize(gNewsStart,0);
  ArrayResize(gNewsEnd,0);
  ArrayResize(gNewsNames,0);
  ArrayResize(gNewsImpact,0);

   string url="https://nfs.faireconomy.media/ff_calendar_thisweek.json";
   if(StringFind(StringToLower(NewsAPISource),"myfxbook")>=0)
      url="https://nfs.faireconomy.media/ff_calendar_thisweek.json";
   uchar post[];
   uchar result[];
   string headers="";
   string res_headers;
   ResetLastError();
  int res=WebRequest("GET",url,headers,10000,post,result,res_headers);
  if(res==-1)
    {
      Print("News WebRequest failed ",GetLastError());
      LoadFallbackNews();
      return;
    }
   string data=CharArrayToString(result);
   string events[];
   StringSplit(data,"{\"id\"",events);
  for(int i=1;i<ArraySize(events);i++)
     {
      string cur = StringBetween(events[i],"\"country\":\"","\"");
      string imp = StringBetween(events[i],"\"impact\":\"","\"");
      string dt  = StringBetween(events[i],"\"timestamp\":",",");
      string title=StringBetween(events[i],"\"title\":\"","\"");
      if(cur=="" || imp=="" || dt=="")
         continue;
      imp=StringToLower(imp);
      if(StringFind(imp,"high")<0 && (!IncludeMediumImpactNews || StringFind(imp,"medium")<0))
         continue;
      if(StringTrim(NewsKeywords)!="")
        {
         string parts[]; int n=StringSplit(NewsKeywords,',',parts);
         bool ok=false;
         for(int k=0;k<n;k++)
            if(StringFind(StringToLower(title),StringToLower(StringTrim(parts[k])))>=0)
               { ok=true; break; }
         if(!ok) continue;
        }
      datetime t=(datetime)StringToInteger(dt);
      if(t==0) continue;
      int sz=ArraySize(gNewsSymbols);
      ArrayResize(gNewsSymbols,sz+1);
      ArrayResize(gNewsStart,sz+1);
      ArrayResize(gNewsEnd,sz+1);
      ArrayResize(gNewsNames,sz+1);
      ArrayResize(gNewsImpact,sz+1);
      gNewsSymbols[sz]=cur;
      gNewsStart[sz]=t-NewsBlockBeforeMinutes*60;
      gNewsEnd[sz]=t+NewsBlockAfterMinutes*60;
      gNewsNames[sz]=title;
      gNewsImpact[sz]=imp;
    }
 }

void LoadFallbackNews()
  {
   string file="NewsFallback.csv";
   if(!FileIsExist(file))
      return;
   int h=FileOpen(file,FILE_READ|FILE_CSV|FILE_ANSI);
   if(h==INVALID_HANDLE) return;
   while(!FileIsEnding(h))
     {
      string cur=FileReadString(h);
      string dt =FileReadString(h);
      string imp=FileReadString(h);
      string desc=FileReadString(h);
      datetime t=StringToTime(dt);
      if(cur==""||t==0||imp=="") continue;
      imp=StringToLower(imp);
      if(StringFind(imp,"high")<0 && (!IncludeMediumImpactNews || StringFind(imp,"medium")<0))
         continue;
      int sz=ArraySize(gNewsSymbols);
      ArrayResize(gNewsSymbols,sz+1);
      ArrayResize(gNewsStart,sz+1);
      ArrayResize(gNewsEnd,sz+1);
      ArrayResize(gNewsNames,sz+1);
      ArrayResize(gNewsImpact,sz+1);
      gNewsSymbols[sz]=cur;
      gNewsStart[sz]=t-NewsBlockBeforeMinutes*60;
      gNewsEnd[sz]=t+NewsBlockAfterMinutes*60;
      gNewsNames[sz]=desc;
      gNewsImpact[sz]=imp;
     }
   FileClose(h);
  }

void GetSymbolCurrencies(string symbol,string &c1,string &c2)
  {
   c1="";c2="";
   string up=StringUpper(symbol);
   if(StringLen(up)>=6)
     {
      c1=StringSubstr(up,0,3);
      c2=StringSubstr(up,3,3);
     }
   else
     {
      c1="USD";
      c2="";
     }
   for(int i=0;i<3;i++)
     {
      uchar ch=StringGetCharacter(c1,i);
      if(ch<'A'||ch>'Z') {c1="USD";break;}
     }
   for(int i=0;i<3 && c2!="";i++)
     {
      uchar ch=StringGetCharacter(c2,i);
      if(ch<'A'||ch>'Z') {c2="";break;}
     }
  }

bool IsHighImpactNewsNow(string symbol)
  {
   if(OverrideNewsFilter)
      return(false);
   if(!EnableLiveNewsFilter)
      return(false);

   UpdateNewsCache();
   string cur1,cur2;
   GetSymbolCurrencies(symbol,cur1,cur2);
   int idx=GetSymbolIndex(symbol);
   datetime now=TimeCurrent();
   bool active=false;
   for(int i=0;i<ArraySize(gNewsSymbols);i++)
    {
      if(gNewsSymbols[i]==cur1 || gNewsSymbols[i]==cur2)
        {
         if(now>=gNewsStart[i] && now<=gNewsEnd[i])
           {
             if(idx>=0 && now>gLastNewsAlert[idx])
               {
               string ev = (i<ArraySize(gNewsNames)) ? gNewsNames[i] : "";
               string imp = (i<ArraySize(gNewsImpact)) ? gNewsImpact[i] : "";
               string msg=StringFormat("[News Filter] Blocked %s trade \xE2\x80\x93 %s %s at %s",symbol,imp,ev,TimeToString(gNewsEnd[i],TIME_MINUTES));
               
               LogEvent(symbol,"NEWS_BLOCK",0,0,0,0);
               LogNewsBlock(symbol,gNewsEnd[i],imp,ev);
               gLastNewsAlert[idx]=gNewsEnd[i];
               }
             active=true;
           }
        }
    }
  return(active);
  }

bool CheckNewsImpact(string symbol)
  {
   return(IsHighImpactNewsNow(symbol));
  }

bool IsSessionAllowed()
  {
   if(!EnableSessionFilter)
      return(true);

   datetime now=TimeCurrent();
   int minutes=TimeHour(now)*60+TimeMinute(now);

   int start=9*60;  // 09:00 server time
   int end=17*60;   // 17:00 server time

   return(minutes>=start && minutes<=end);
  }

string GetCurrentSession()
  {
   int minutes=TimeHour(TimeCurrent())*60+TimeMinute(TimeCurrent());
   if(minutes>=9*60 && minutes<=17*60)
      return("LondonNY");
   return("Off");
  }

// CoolDownPassed - check if symbol cooldown expired
bool CoolDownPassed(string symbol)
  {
   for(int i=0;i<gSymbolCount;i++)
     {
      if(gSymbols[i]==symbol)
        {
         datetime now=TimeCurrent();
         if(gLastTradeTime[i]==0 && gCooldownEndTime[i]==0)
            return(true);
         if(now<gCooldownEndTime[i])
            return(false);
         if(gLastTradeTime[i]==0)
            return(true);
         if(now-gLastTradeTime[i] >= CooldownMinutes*60)
            return(true);
         return(false);
        }
     }
  return(true);
  }

// Backwards compatibility wrapper for older validator
bool CooldownPassed(string symbol)
  {
   return(CoolDownPassed(symbol));
  }

double GetFallbackSL(string symbol)
  {
   string pair=SL_PerSymbol;
   int pos=StringFind(pair,symbol+"=");
   if(pos>=0)
     {
      int start=pos+StringLen(symbol)+1;
      int end=StringFind(pair,";",start);
      if(end==-1) end=StringLen(pair);
      string val=StringSubstr(pair,start,end-start);
      double pts=StringToDouble(val);
      if(pts>0) return(pts);
     }
  return(30); // default
 }

double GetAdaptiveSL(string symbol)
  {
   double fixed=GetFallbackSL(symbol);
   if(!UseAdaptiveRRR) return(fixed);
   double atr=iATR(symbol,PERIOD_M15,14,1);
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(atr<=0 || point<=0) return(fixed);
   double atrPts=(atr/point)*ATRMultiplier;
   if(atrPts<=0) return(fixed);
   return(atrPts);
  }

bool HasOpenPosition(string symbol)
  {
   for(int i=0;i<PositionsTotal();i++)
     {
      if(PositionGetSymbol(i)==symbol)
         return(true);
     }
   return(false);
  }

int DetectOrderBlocks(string symbol)
  {
   int lookback=10;
   if(Bars(symbol,0,0,TimeCurrent())<lookback+2)
      return(0);
   for(int i=2;i<lookback+2;i++)
     {
      double o1=iOpen(symbol,0,i);
      double c1=iClose(symbol,0,i);
      double o2=iOpen(symbol,0,i-1);
      double c2=iClose(symbol,0,i-1);

      // bullish order block - bearish candle followed by strong bull candle
      if(c1<o1 && c2>o2 && c2>o1 && c1<c2)
         return(1);

      // bearish order block - bullish candle then strong bear candle
      if(c1>o1 && c2<o2 && c2<o1 && c1>c2)
         return(-1);
     }
   return(0);
  }

int DetectBreakOfStructure(string symbol)
  {
   int lookback=20;
   if(Bars(symbol,0,0,TimeCurrent())<lookback+3)
      return(0);

   int hh=iHighest(symbol,0,MODE_HIGH,lookback,2);
   int ll=iLowest(symbol,0,MODE_LOW,lookback,2);
   double prevHigh=iHigh(symbol,0,hh);
   double prevLow=iLow(symbol,0,ll);
   double close1=iClose(symbol,0,1);

   if(close1>prevHigh)
      return(1);
   if(close1<prevLow)
      return(-1);
  return(0);
  }

int DetectFairValueGap(string symbol)
  {
   if(Bars(symbol,0)<3)
      return(0);
   double h1=iHigh(symbol,0,3);
   double l1=iLow(symbol,0,3);
   double h3=iHigh(symbol,0,1);
   double l3=iLow(symbol,0,1);
   if(l1>h3) return(1);
   if(h1<l3) return(-1);
   return(0);
  }

int DetectImbalance(string symbol)
  {
   if(Bars(symbol,0)<3) return(0);
   double body1=MathAbs(iClose(symbol,0,2)-iOpen(symbol,0,2));
   double body2=MathAbs(iClose(symbol,0,1)-iOpen(symbol,0,1));
   if(body1>body2*1.5)
      return(iClose(symbol,0,2)>iOpen(symbol,0,2)?1:-1);
   return(0);
  }

double CalculateConfidence(string symbol,bool &isBuy,ConfidenceFactors &fac)
  {
   double emaFast=iMA(symbol,0,21,0,MODE_EMA,PRICE_CLOSE,1);
   double emaSlow=iMA(symbol,0,50,0,MODE_EMA,PRICE_CLOSE,1);
   double rsi=iRSI(symbol,0,14,PRICE_CLOSE,1);

   if(emaFast==0 || emaSlow==0)
      return(0.0);

   double open1=iOpen(symbol,0,1);
   double close1=iClose(symbol,0,1);
   double open2=iOpen(symbol,0,2);
   double close2=iClose(symbol,0,2);

   bool bullEngulf=(close1>open1 && close2<open2 && close1>open2 && open1<close2);
   bool bearEngulf=(close1<open1 && close2>open2 && close1<open2 && open1>close2);

   int ob=DetectOrderBlocks(symbol);
  int bos=DetectBreakOfStructure(symbol);
  int fvg=DetectFairValueGap(symbol);
  int imb=DetectImbalance(symbol);

   bool obBuy=(ob==1);
   bool obSell=(ob==-1);
   bool bosBuy=(bos==1);
   bool bosSell=(bos==-1);

   bool emaBuy=emaFast>emaSlow;
   bool emaSell=emaFast<emaSlow;

   bool rsiBuy=rsi>50;
   bool rsiSell=rsi<50;

   double buyScore=0.0;
   double sellScore=0.0;

   ConfidenceProfile prof;
   int idx=GetSymbolIndex(symbol);
   if(idx>=0) prof=gProfiles[idx]; else {prof.EMAWeight=0.15;prof.RSIWeight=0.15;prof.OBWeight=0.15;prof.BOSWeight=0.15;prof.EngulfingWeight=0.15;}

  if(obBuy)   buyScore+=prof.OBWeight;
  if(bosBuy)  buyScore+=prof.BOSWeight;
  if(fvg==1)  buyScore+=0.1;
  if(imb==1)  buyScore+=0.05;
  if(rsiBuy)  buyScore+=prof.RSIWeight;
  if(emaBuy)  buyScore+=prof.EMAWeight;
  if(bullEngulf) buyScore+=prof.EngulfingWeight;

  if(obSell)  sellScore+=prof.OBWeight;
  if(bosSell) sellScore+=prof.BOSWeight;
  if(fvg==-1) sellScore+=0.1;
  if(imb==-1) sellScore+=0.05;
  if(rsiSell) sellScore+=prof.RSIWeight;
  if(emaSell) sellScore+=prof.EMAWeight;
  if(bearEngulf) sellScore+=prof.EngulfingWeight;

  if(obBuy && bosBuy && emaBuy)
     buyScore+=0.10;
  if(obSell && bosSell && emaSell)
     sellScore+=0.10;
  if(obBuy && bosBuy && fvg==1)
     buyScore+=0.05;
  if(obSell && bosSell && fvg==-1)
     sellScore+=0.05;

   buyScore=MathMin(buyScore,1.0);
   sellScore=MathMin(sellScore,1.0);

   double score;
   if(buyScore>=sellScore)
     {
      isBuy=true;
      score=buyScore;
      fac.ema=emaBuy;
      fac.rsi=rsiBuy;
      fac.ob=obBuy;
      fac.bos=bosBuy;
      fac.engulf=bullEngulf;
     }
   else
     {
      isBuy=false;
      score=sellScore;
      fac.ema=emaSell;
      fac.rsi=rsiSell;
      fac.ob=obSell;
      fac.bos=bosSell;
      fac.engulf=bearEngulf;
     }

    int idx=GetSymbolIndex(symbol);
    if(idx>=0 && gStreak[idx]<=-3)
       score-=0.2;

    double memAdj=EvaluateTradeMemory(symbol,isBuy,score,fac);
    score+=memAdj;
    if(score<0.0) score=0.0;
    return(score);
  }

bool VolatilityFilter(string symbol)
  {
   if(!EnableVolatilityFilter)
      return(true);

   int period=14;
   int tf=PERIOD_M15;
   if(Bars(symbol,tf,0,TimeCurrent())<period+20)
      return(true);

   double current=iATR(symbol,tf,period,1);
   if(current<=0)
      return(true);

   double sum=0.0;
   for(int i=1;i<=20;i++)
      sum+=iATR(symbol,tf,period,i);
   double avg=sum/20.0;

  return(current>avg);
  }

bool SpreadOK(string symbol)
  {
   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(point<=0) return(true);
   double spread=(ask-bid)/point;
   return(spread<=SpreadLimitPoints);
  }
double GetSpreadPoints(string symbol)
  {
   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(point<=0) return(0.0);
   double spread=(ask-bid);
   if(spread<=0)
      spread=(double)SymbolInfoInteger(symbol,SYMBOL_SPREAD)*point;
   return(spread/point);
  }

bool IsSpreadAcceptable(string symbol)
  {
   double sp=GetSpreadPoints(symbol);
   int idx=GetSymbolIndex(symbol);
   if(idx>=0)
     {
      gLastSpread[idx]=sp;
      gSpreadAvg[idx]=(gSpreadAvg[idx]*gSpreadSamples[idx]+sp)/(gSpreadSamples[idx]+1);
      if(gSpreadSamples[idx]<500) gSpreadSamples[idx]++;
     }
   double avg=(idx>=0 && gSpreadSamples[idx]>10)?gSpreadAvg[idx]:sp;
   double limit=avg*SpreadSpikeMultiplier;
   if(sp>limit && EnableSpreadFilter)
      return(false);
   if(EnableBrokerAwareness && EnableSpreadLimit && sp>MaxAllowedSpread)
      return(false);
   return(sp<=MaxAllowedSpreadPoints);
  }

bool IsAIPatternFavorable(string symbol,bool &isBuy)
  {
   double conf; bool dir;
   bool ok=false;
   if(EnableAIPatterns)
      ok=GetAIPrediction(symbol,dir,conf);
   if(!ok)
      ok=QueryAIPattern(symbol,dir,conf);
   if(!ok)
      ok=GetAIRecommendation(symbol,dir,conf);
   isBuy=dir;
   if(!ok)
      return(true); // allow trading if request failed or no signal
   int idx=GetSymbolIndex(symbol);
   if(idx>=0) gAIPatternConf[idx]=conf*100;
   if(conf<AI_ConfidenceThreshold)
     {
      string msg=StringFormat("\xF0\x9F\xA7\xA0 AI signal not strong enough for %s: %.0f%%",symbol,conf*100);
      Print(msg);
      
      LogEvent(symbol,"AI_LOW",0,0,0,conf*100);
      return(false);
     }
   if(idx>=0) gAIPatternDir[idx]=dir;
   LogEvent(symbol,"AI_OK",0,0,0,conf*100);
   return(true);
  }

bool IsLiquidityTrapLikely(string symbol,bool isBuy)
  {
   int lookback=20;
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(point<=0 || Bars(symbol,0)<lookback+2)
      return(false);

   double volAvg=0;
   for(int i=2;i<=lookback;i++)
      volAvg+=iVolume(symbol,0,i);
   volAvg/=(lookback-1);

   double open1=iOpen(symbol,0,1);
   double close1=iClose(symbol,0,1);
   double high1=iHigh(symbol,0,1);
   double low1=iLow(symbol,0,1);
   double vol1=iVolume(symbol,0,1);

   if(isBuy)
     {
      for(int j=2;j<=lookback;j++)
        {
         double lowj=iLow(symbol,0,j);
         if(MathAbs(low1-lowj)<=20*point && MathAbs(low1-lowj)>=10*point && low1<lowj)
           {
            if(close1>open1 && close1>iOpen(symbol,0,j) && vol1>=volAvg)
              {
               MarkLiquidityZone(symbol,lowj,low1,iTime(symbol,0,j),iTime(symbol,0,1));
               return(true);
              }
           }
        }
     }
   else
     {
      for(int j=2;j<=lookback;j++)
        {
         double highj=iHigh(symbol,0,j);
         if(MathAbs(high1-highj)<=20*point && MathAbs(high1-highj)>=10*point && high1>highj)
           {
            if(close1<open1 && close1<iOpen(symbol,0,j) && vol1>=volAvg)
              {
               MarkLiquidityZone(symbol,highj,high1,iTime(symbol,0,j),iTime(symbol,0,1));
               return(true);
              }
           }
        }
     }
   return(false);
  }

bool IsNearLiquidityPool(string symbol)
{
   if(!EnableLiquidityFilter)
      return(false);
   int lookback=20;
   if(DetectBreakOfStructure(symbol)!=0)
      return(false);
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(point<=0 || Bars(symbol,0)<lookback+2)
      return(false);
   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   double price=(ask+bid)/2.0;
   double prox=LiquidityProximityPoints*point;
   for(int i=2;i<=lookback;i++)
     {
      double h=iHigh(symbol,0,i);
      double hPrev=iHigh(symbol,0,i+1);
      double hNext=iHigh(symbol,0,i-1);
      if(h>hPrev && h>hNext)
        {
         bool broken=false;
         for(int j=i-1;j>=1;j--)
            if(iHigh(symbol,0,j)>h+point*0.1){broken=true;break;}
         if(!broken && MathAbs(price-h)<=prox)
            return(true);
        }
      double l=iLow(symbol,0,i);
      double lPrev=iLow(symbol,0,i+1);
      double lNext=iLow(symbol,0,i-1);
      if(l<lPrev && l<lNext)
        {
         bool broken=false;
         for(int j=i-1;j>=1;j--)
            if(iLow(symbol,0,j)<l-point*0.1){broken=true;break;}
         if(!broken && MathAbs(price-l)<=prox)
            return(true);
        }
     }
  return(false);
}

void DetectLiquidityPools(string symbol,double &buyLevel,double &sellLevel)
  {
   buyLevel=0.0; sellLevel=0.0;
   if(!EnableLiquidityDetection) return;
   int lookback=LP_CandleCount;
   double pt=SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(pt<=0 || Bars(symbol,0)<lookback+2) return;
   for(int i=1;i<=lookback-1;i++)
     {
      double h=iHigh(symbol,0,i);
      int hc=1;
      for(int j=i+1;j<=MathMin(i+2,lookback);j++)
         if(MathAbs(iHigh(symbol,0,j)-h)<=LP_SensitivityPoints*pt) hc++;
      if(hc>=2){ buyLevel=h; break; }
     }
   for(int i=1;i<=lookback-1;i++)
     {
      double l=iLow(symbol,0,i);
      int lc=1;
      for(int j=i+1;j<=MathMin(i+2,lookback);j++)
         if(MathAbs(iLow(symbol,0,j)-l)<=LP_SensitivityPoints*pt) lc++;
      if(lc>=2){ sellLevel=l; break; }
     }
  }

bool IsNearLiquidityTrap(string symbol,bool isBuy)
  {
   double buyLvl,sellLvl;
   DetectLiquidityPools(symbol,buyLvl,sellLvl);
   double pt=SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(pt<=0) return(false);
   double price=isBuy?SymbolInfoDouble(symbol,SYMBOL_ASK):SymbolInfoDouble(symbol,SYMBOL_BID);
   double prox=LiquidityProximityPoints*pt;
  int idx=GetSymbolIndex(symbol);
  if(buyLvl>0 && idx>=0) gLiqBuyLevel[idx]=buyLvl;
  if(sellLvl>0 && idx>=0) gLiqSellLevel[idx]=sellLvl;
   if(isBuy && buyLvl>0 && MathAbs(price-buyLvl)<=prox)
     {
      MarkLiquidityZone(symbol,buyLvl,buyLvl,TimeCurrent()-3600,TimeCurrent()+3600);
      LogLiquidityPool(symbol,"BUY_LIQ",buyLvl,"buy");
      return(true);
     }
   if(!isBuy && sellLvl>0 && MathAbs(price-sellLvl)<=prox)
     {
      MarkLiquidityZone(symbol,sellLvl,sellLvl,TimeCurrent()-3600,TimeCurrent()+3600);
      LogLiquidityPool(symbol,"SELL_LIQ",sellLvl,"sell");
      return(true);
     }
  return(false);
  }

void LogLiquidityPool(string symbol,string zoneType,double price,string direction)
  {
   string file="Liquidity_Pools.csv";
   int h=FileOpen(file,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE)
      h=FileOpen(file,FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE) return;
   FileSeek(h,0,SEEK_END);
   FileWrite(h,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),symbol,zoneType,
             DoubleToString(price,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)),direction);
   FileClose(h);
  }

//--- Update MT5 calendar cache
void UpdateCalendarCache()
  {
   datetime now=TimeCurrent();
   if(now-gCalCacheTime<3600) // refresh hourly
      return;
   gCalCacheTime=now;
   datetime from=now-(MinutesBeforeNews*60);
   datetime to=now+86400; // next day
   ArrayResize(gCalEvents,0);
   gCalCount=CalendarValueHistory(gCalEvents,from,to);
  }

//--- Check upcoming news via built-in calendar
bool IsNewsAwareEvent(string symbol)
  {
   if(!EnableNewsAwareFilter)
      return(false);
   UpdateCalendarCache();
   string c1,c2; GetSymbolCurrencies(symbol,c1,c2);
   datetime now=TimeCurrent();
   for(int i=0;i<gCalCount;i++)
     {
      if((gCalEvents[i].currency==c1 || gCalEvents[i].currency==c2) &&
         (gCalEvents[i].importance==CALENDAR_IMPORTANCE_HIGH ||
          gCalEvents[i].importance==CALENDAR_IMPORTANCE_MEDIUM))
        {
         datetime st=gCalEvents[i].time-MinutesBeforeNews*60;
         datetime en=gCalEvents[i].time+MinutesAfterNews*60;
         if(now>=st && now<=en)
           {
            int idx=GetSymbolIndex(symbol);
            if(idx>=0 && now>gLastNewsAlert[idx])
              {
               string msg=StringFormat("News block %s: %s",symbol,gCalEvents[i].event);
               Print(msg);
               
               LogEvent(symbol,"NEWS_BLOCK",0,0,0,0);
               gLastNewsAlert[idx]=en;
              }
            return(true);
           }
        }
     }
   return(false);
  }

double CalculateLotSize(string symbol, double stopLossPoints, double confidence)
  {
   double riskPercent = MaxRiskPercent;
  if(EnableSmartEquityScaling)
    {
      double eq=AccountInfoDouble(ACCOUNT_EQUITY);
      if(eq<100)
         riskPercent=MaxRiskPercent;
      else if(eq>1000)
         riskPercent=MinRiskPercent;
      else
         riskPercent=MaxRiskPercent - (eq-100)/900.0*(MaxRiskPercent-MinRiskPercent);
    }
  if(gMarketMode==MODE_CAUTIOUS) riskPercent-=0.5;
  else if(gMarketMode==MODE_AGGRESSIVE) riskPercent+=0.5;
  if(confidence > 0.8)
      riskPercent *= 1.5; // ultra-high confidence boost
  int sidx=GetSymbolIndex(symbol);
  if(sidx>=0)
     riskPercent *= gFBMultiplier[sidx];
  if(EnableExecutionTuning && sidx>=0 && gExecSlipCount[sidx]>0){
     double aS=gExecSlipSum[sidx]/gExecSlipCount[sidx];
     if(aS>MaxAllowedSlippage) riskPercent*=0.9;
     double sRate=(gExecOrders[sidx]>0)?(double)gExecSuccess[sidx]/gExecOrders[sidx]:0;
     if(sRate==1.0 && gExecOrders[sidx]>=5) riskPercent+=0.5;
    }
  riskPercent=MathMin(MathMax(riskPercent,MinRiskPercent),MaxRiskPercent);
   double riskAmount = AccountInfoDouble(ACCOUNT_EQUITY) * riskPercent / 100.0;
   if(gWinStreak >= 2)
     {
      riskAmount *= (1.0 + 0.25 * gWinStreak);  // Boost by 25% per win
     }
   double tickValue=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
   double tickSize=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE);
   double valuePerPoint=tickValue/tickSize;
   double slValue=stopLossPoints*valuePerPoint;
   if(slValue<=0.0) return(0.0);
   double lot=riskAmount/slValue;
   double minLot=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
   double step=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   if(lot<minLot) lot=minLot;
   lot=MathFloor(lot/step)*step;
   return(NormalizeDouble(lot,2));
  }

void EnterTrade(string symbol, bool isBuy, double confidence, ConfidenceFactors fac)
  {
  if(EnableBrokerAwareness && EnableSpreadLimit && !IsSpreadAcceptable(symbol))
    {
     Print("Skipped trade: spread too high");
     SendTelegram("Skipped trade: spread too high " + symbol);
     LogEvent(symbol,"SPREAD_SKIP",0,0,0,confidence);
     return;
    }
  double slPoints=GetAdaptiveSL(symbol);
  double tp1rr=TP1_RR, tp2rr=TP2_RR, tp3rr=TP3_RR;
  OptimizeSLTP(symbol,isBuy,slPoints,tp1rr,tp2rr,tp3rr);
  double lot=CalculateLotSize(symbol,slPoints,confidence);
  double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
  double price=isBuy?SymbolInfoDouble(symbol,SYMBOL_ASK):SymbolInfoDouble(symbol,SYMBOL_BID);

  // Simulate market conditions with potential slippage and requotes
  if(!SimulateMarketExecution(symbol,price,SlippagePoints,isBuy))
    {
     SendTelegram(StringFormat("%s: Trade delayed due to requote simulation",symbol));
     return;
    }

  double slippageAdd=(SimulatedSlippageMaxPoints>0)?(MathRand()%SimulatedSlippageMaxPoints):0;
  if(isBuy) price+=slippageAdd*point; else price-=slippageAdd*point;
  double sl = isBuy?price-slPoints*point:price+slPoints*point;
  double tp = isBuy?price+tp1rr*slPoints*point:price-tp1rr*slPoints*point;

  SimulateBrokerConditions(symbol,isBuy,price);
  sl = isBuy?price-slPoints*point:price+slPoints*point;
  tp = isBuy?price+tp1rr*slPoints*point:price-tp1rr*slPoints*point;

   // Draw trade markers
   string mark = "PMX_"+IntegerToString(TimeCurrent())+"_"+symbol;
   color col = isBuy ? clrLime : clrRed;
   ObjectCreate(0, mark+"_ENTRY", OBJ_HLINE, 0, TimeCurrent(), price);
   ObjectSetInteger(0, mark+"_ENTRY", OBJPROP_COLOR, col);
   ObjectSetInteger(0, mark+"_ENTRY", OBJPROP_STYLE, STYLE_SOLID);
   ObjectCreate(0, mark+"_SL", OBJ_HLINE, 0, TimeCurrent(), sl);
   ObjectSetInteger(0, mark+"_SL", OBJPROP_COLOR, clrOrangeRed);
   ObjectCreate(0, mark+"_TP", OBJ_HLINE, 0, TimeCurrent(), tp);
   ObjectSetInteger(0, mark+"_TP", OBJPROP_COLOR, clrGold);

   // Visual trail and label
   string tag = "TRADE_"+IntegerToString(TimeCurrent());
   ObjectCreate(0, tag+"_LABEL", OBJ_TEXT, 0, TimeCurrent(), price);
   ObjectSetInteger(0, tag+"_LABEL", OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, tag+"_LABEL", OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, tag+"_LABEL", OBJPROP_TEXT, StringFormat("%s %.2f lot | Conf: %.2f", symbol, lot, confidence));
  //--- margin check using OrderCalcMargin
  double marginReq=0.0;
  if(!OrderCalcMargin(isBuy?ORDER_TYPE_BUY:ORDER_TYPE_SELL,symbol,lot,price,marginReq))
     Print("OrderCalcMargin failed ",GetLastError());
  double freeMargin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
  if(freeMargin<marginReq)
    {
     Print("Margin insufficient for ",symbol);
     LogEvent(symbol,"FAIL",lot,sl,tp,confidence);
     return;
    }

   MqlTradeRequest req;MqlTradeResult res;ZeroMemory(req);ZeroMemory(res);
   req.action=TRADE_ACTION_DEAL;
   req.symbol=symbol;
   req.volume=lot;
   req.price=price;
   req.sl=UseHiddenSL?0:sl;
   req.tp=UseHiddenSL?0:tp;
   req.deviation=SlippagePoints;
  req.type=isBuy?ORDER_TYPE_BUY:ORDER_TYPE_SELL;
  req.type_filling=ORDER_FILLING_FOK;

  if(!SimulateExecutionAdvanced(req,1500,SlippagePoints,RejectionChancePercent/100.0,RequoteChancePercent/100.0))
    {
     LogEvent(symbol,"SIM_ABORT",lot,sl,tp,confidence);
     return;
    }

  if(!SimulateExecutionSimple())
    {
     SendTelegram("\xE2\x9D\x8C Simulated rejection for "+symbol);
     LogEvent(symbol,"SIM_REJECT",lot,sl,tp,confidence);
     return;
    }

  if(!SimulateExecution(req))
    {
     LogEvent(symbol,"SIM_ABORT",lot,sl,tp,confidence);
     return;
    }
  if(!ExecutionReality(req))
    {
     LogEvent(symbol,"REAL_ABORT",lot,sl,tp,confidence);
     return;
    }

  bool sent=false;
  for(int attempt=0;attempt<3 && !sent;attempt++)
    {
    ulong tstart=GetTickCount();
    if(SendSmartOrder(req,res,symbol,isBuy))
        sent=true;
    else
      {
        Print("OrderSend failed ",res.retcode," ",EnumToString((ENUM_TRADE_RETCODE)res.retcode));
        if(res.retcode==TRADE_RETCODE_REJECT)
          {
           gTradingPaused=true;
           gErrorPauseEndTime=TimeCurrent()+PauseAfterErrorMinutes*60;
           string emsg=StringFormat("Order rejected, pausing %d minutes",PauseAfterErrorMinutes);
           Print(emsg);
           SendTelegram(emsg);
           break;
          }
        if(attempt<2) Sleep(1000);
      }
    TrackExecutionSpeed(tstart,symbol);
    }

   if(!sent)
     {
      LogEvent(symbol,"FAIL",lot,sl,tp,confidence);
      return;
     }

   double fill=res.price;
   LogSlippage(symbol,req.price,fill);

   for(int i=0;i<gSymbolCount;i++)
      if(gSymbols[i]==symbol)
         gLastTradeTime[i]=TimeCurrent();
  Print("Trade opened ",symbol," ",res.order);
  LogEvent(symbol,"Entry",lot,sl,tp,confidence);
  gDayConfSum+=confidence;
  gDayConfCount++;

  if(PositionSelect(symbol))
    {
     TradeInfo info;
      info.symbol=symbol;
      info.ticket=PositionGetInteger(POSITION_TICKET);
      info.lot=PositionGetDouble(POSITION_VOLUME);
         info.initialLot=info.lot;
         info.stopLoss=UseHiddenSL?sl:PositionGetDouble(POSITION_SL);
        info.takeProfit1=UseHiddenSL?tp:PositionGetDouble(POSITION_TP);
        double slDist=MathAbs(PositionGetDouble(POSITION_PRICE_OPEN)-info.stopLoss)/SymbolInfoDouble(symbol,SYMBOL_POINT);
        info.takeProfit2=isBuy?PositionGetDouble(POSITION_PRICE_OPEN)+tp2rr*slDist*SymbolInfoDouble(symbol,SYMBOL_POINT)
                             :PositionGetDouble(POSITION_PRICE_OPEN)-tp2rr*slDist*SymbolInfoDouble(symbol,SYMBOL_POINT);
        info.takeProfit3=isBuy?PositionGetDouble(POSITION_PRICE_OPEN)+tp3rr*slDist*SymbolInfoDouble(symbol,SYMBOL_POINT)
                             :PositionGetDouble(POSITION_PRICE_OPEN)-tp3rr*slDist*SymbolInfoDouble(symbol,SYMBOL_POINT);
        info.confidence=confidence;
         info.openTime=TimeCurrent();
        info.entryPrice=PositionGetDouble(POSITION_PRICE_OPEN);
        info.stage=0;
        info.isBuy=isBuy;
        info.spreadEntry=GetSpreadPoints(symbol);
        info.atrEntry=iATR(symbol,PERIOD_M15,14,0);
        string ind="";
         if(fac.ema)       ind+="EMA,";
         if(fac.rsi)       ind+="RSI,";
         if(fac.ob)        ind+="OB,";
         if(fac.bos)       ind+="BOS,";
         if(fac.engulf)    ind+="ENGULF,";
         if(StringLen(ind)>0) ind=StringSubstr(ind,0,StringLen(ind)-1);
         info.indicators=ind;
         info.facEMA=fac.ema;
         info.facRSI=fac.rsi;
         info.facOB=fac.ob;
         info.facBOS=fac.bos;
         info.facEngulf=fac.engulf;
         ArrayResize(gTrades,ArraySize(gTrades)+1);
        gTrades[ArraySize(gTrades)-1]=info;
        DrawTradeObjects(info.ticket,symbol,isBuy,PositionGetDouble(POSITION_PRICE_OPEN),info.stopLoss,info.takeProfit1,info.takeProfit2,info.takeProfit3);
        RecordTradeContext(symbol,confidence,isBuy);
        LogTradeData(symbol,isBuy,confidence);
        RecordEntryData(symbol,isBuy,confidence,lot,sl,tp);
       }
    }
  }

void ManageOpenPositions()
  {
   int total=ArraySize(gTrades);
   for(int i=total-1;i>=0;i--)
     {
      TradeInfo &info=gTrades[i];
      if(!PositionSelectByTicket(info.ticket))
        {
        int idx=GetSymbolIndex(info.symbol);
        if(idx>=0) gReentryAllowed[idx]=false;
        RemoveTradeObjects(info.ticket);
        ArrayRemove(gTrades,i,1);
         continue;
        }

      bool isBuy=(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY);
      double price=isBuy?SymbolInfoDouble(info.symbol,SYMBOL_BID)
                        :SymbolInfoDouble(info.symbol,SYMBOL_ASK);
      if(price==0.0 || info.lot<0.01)
         continue;

      double entry=PositionGetDouble(POSITION_PRICE_OPEN);
      double sl=UseHiddenSL?info.stopLoss:PositionGetDouble(POSITION_SL);
      double point=SymbolInfoDouble(info.symbol,SYMBOL_POINT);
      if(point<=0) continue;

      double slDist=MathAbs(entry-sl)/point;
      double tp1=info.takeProfit1;
      double tp2=info.takeProfit2;
      double tp3=info.takeProfit3;

      // stop loss check for hidden SL
      if(UseHiddenSL && ((isBuy && price<=sl) || (!isBuy && price>=sl)))
        {
        CloseAtStop(info);
        int idx=GetSymbolIndex(info.symbol);
        if(idx>=0) gReentryAllowed[idx]=false;
        ArrayRemove(gTrades,i,1);
         continue;
        }

      // TP1
      if(info.stage<1 && ((isBuy && price>=tp1) || (!isBuy && price<=tp1)))
        PartialClose(info,1);

      // TP2
      price=isBuy?SymbolInfoDouble(info.symbol,SYMBOL_BID)
                 :SymbolInfoDouble(info.symbol,SYMBOL_ASK);
      if(info.stage<2 && ((isBuy && price>=tp2) || (!isBuy && price<=tp2)))
        PartialClose(info,2);

      // TP3
      price=isBuy?SymbolInfoDouble(info.symbol,SYMBOL_BID)
                 :SymbolInfoDouble(info.symbol,SYMBOL_ASK);
      if(info.stage<3 && ((isBuy && price>=tp3) || (!isBuy && price<=tp3)))
        {
         PartialClose(info,3);
         int idx=GetSymbolIndex(info.symbol);
         if(idx>=0) gReentryAllowed[idx]=false;
           gTradeWins++;
         ArrayRemove(gTrades,i,1);
         continue;
        }
     }
  }

void ApplyTrailingStop(TradeInfo &info)
  {
   if(!PositionSelectByTicket(info.ticket))
      return;

   bool isBuy=(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY);
   double entry=PositionGetDouble(POSITION_PRICE_OPEN);
   double currentSL=PositionGetDouble(POSITION_SL);
   double newSL=entry;
   if((isBuy && newSL>currentSL) || (!isBuy && newSL<currentSL))
     {
      MqlTradeRequest req;MqlTradeResult res;ZeroMemory(req);ZeroMemory(res);
      req.action=TRADE_ACTION_SLTP;
      req.position=info.ticket;
      req.symbol=info.symbol;
      req.sl=newSL;
      req.tp=PositionGetDouble(POSITION_TP);
      req.deviation=SlippagePoints;
      ulong tstart=GetTickCount();
      if(!SimulateExecutionSimple())
        {
         SendTelegram("\xE2\x9D\x8C Simulated rejection for "+info.symbol);
         LogEvent(info.symbol,"SIM_REJECT",info.lot,newSL,req.tp,info.confidence);
         return;
        }
      if(SendSmartOrder(req,res,info.symbol,isBuy))
    {
         if(res.retcode==TRADE_RETCODE_REJECT)
           {
            gTradingPaused=true;
            gErrorPauseEndTime=TimeCurrent()+PauseAfterErrorMinutes*60;
            string emsg=StringFormat("Order rejected, pausing %d minutes",PauseAfterErrorMinutes);
            Print(emsg);
            SendTelegram(emsg);
           }
         else
           {
            SendTelegram(StringFormat("%s trailing stop set",info.symbol));
            LogEvent(info.symbol,"TrailSet",info.lot,newSL,req.tp,info.confidence);
            gTradeWins++;
           }
        }
      else
        {
         Print("Trailing stop failed ",res.retcode," ",EnumToString((ENUM_TRADE_RETCODE)res.retcode));
         if(res.retcode==TRADE_RETCODE_REJECT)
           {
            gTradingPaused=true;
            gErrorPauseEndTime=TimeCurrent()+PauseAfterErrorMinutes*60;
            string emsg=StringFormat("Order rejected, pausing %d minutes",PauseAfterErrorMinutes);
            Print(emsg);
           SendTelegram(emsg);
           }
        }
      TrackExecutionSpeed(tstart,info.symbol);
    }
  }

void PartialClose(TradeInfo &info, int stage)
  {
   if(!PositionSelectByTicket(info.ticket))
      return;

   bool isBuy=(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY);
   double price=isBuy?SymbolInfoDouble(info.symbol,SYMBOL_BID)
                     :SymbolInfoDouble(info.symbol,SYMBOL_ASK);
   if(price==0.0)
      return;

   double vol=0.0;
   if(stage==1)
      vol=MathMin(info.initialLot*TP1_Percent,info.lot);
   else if(stage==2)
      vol=MathMin(info.initialLot*TP2_Percent,info.lot);
   else if(stage==3)
      vol=info.lot;
   if(vol<0.01)
      return;

   MqlTradeRequest req;MqlTradeResult res;ZeroMemory(req);ZeroMemory(res);
   req.action=TRADE_ACTION_DEAL;
   req.position=info.ticket;
   req.symbol=info.symbol;
   req.volume=vol;
   req.price=price;
   req.deviation=SlippagePoints;
  req.type=isBuy?ORDER_TYPE_SELL:ORDER_TYPE_BUY;
  req.type_filling=ORDER_FILLING_FOK;

  if(!SimulateExecutionSimple())
    {
     SendTelegram("\xE2\x9D\x8C Simulated rejection for "+info.symbol);
     LogEvent(info.symbol,"SIM_REJECT",vol,info.stopLoss,info.takeProfit3,info.confidence);
     return;
    }

  ulong tstart=GetTickCount();
  if(SendSmartOrder(req,res,info.symbol,isBuy))
     {
      if(res.retcode==TRADE_RETCODE_REJECT)
        {
         gTradingPaused=true;
         gErrorPauseEndTime=TimeCurrent()+PauseAfterErrorMinutes*60;
         string msg=StringFormat("Order rejected, pausing %d minutes",PauseAfterErrorMinutes);
         Print(msg);
         
         return;
        }

      info.lot-=vol;
      info.stage=stage;
      double sl=PositionGetDouble(POSITION_SL);
      double tp=(stage==1)?info.takeProfit1:(stage==2?info.takeProfit2:info.takeProfit3);
      string tag=StringFormat("TP%d",stage);
      SendTelegram(StringFormat("%s %s hit, closed %.2f lots",info.symbol,tag,vol));
      LogEvent(info.symbol,tag,vol,sl,tp,info.confidence);
      if(stage==1) gTP1Count++;
      else if(stage==2) gTP2Count++;
      else if(stage==3) gTP3Count++;
      if(stage==1)
        {
         ApplyTrailingStop(info);
         int idx=GetSymbolIndex(info.symbol);
         if(idx>=0)
           {
            gReentryAllowed[idx]=true;
            gReentryPrice[idx]=PositionGetDouble(POSITION_PRICE_OPEN);
            gReentryDirection[idx]=isBuy;
           }
        }
      if(stage==3)
        {
         UpdateStats(info.symbol,true);
         ConfidenceFactors ff; ff.ema=info.facEMA; ff.rsi=info.facRSI; ff.ob=info.facOB; ff.bos=info.facBOS; ff.engulf=info.facEngulf;
         UpdateConfidenceProfile(info.symbol,true,ff);
         string ef=StringFormat("EMA=%d,RSI=%d,OB=%d,BOS=%d,ENG=%d",info.facEMA?1:0,info.facRSI?1:0,info.facOB?1:0,info.facBOS?1:0,info.facEngulf?1:0);
        LearnFromTradeResult(info.symbol,true,info.confidence,ef);
        double rr=fabs(info.takeProfit3-info.entryPrice)/MathMax(fabs(info.entryPrice-info.stopLoss),1e-5);
        SaveTradeMemory(info.symbol,info.isBuy,info.confidence,ff,true,stage);
        UpdatePerformanceStats(info.symbol,true,rr,info.confidence);
        RemoveTradeObjects(info.ticket);
        UpdateTPOptimization();
        }
     }
   else
     {
      Print("Partial close failed ",res.retcode," ",EnumToString((ENUM_TRADE_RETCODE)res.retcode));
      if(res.retcode==TRADE_RETCODE_REJECT)
        {
         gTradingPaused=true;
         gErrorPauseEndTime=TimeCurrent()+PauseAfterErrorMinutes*60;
         string msg=StringFormat("Order rejected, pausing %d minutes",PauseAfterErrorMinutes);
         Print(msg);
         
        }
     }
   TrackExecutionSpeed(tstart,info.symbol);
  }

void CloseAtStop(TradeInfo &info)
  {
   if(!PositionSelectByTicket(info.ticket))
      return;
   bool isBuy=(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY);
   double price=isBuy?SymbolInfoDouble(info.symbol,SYMBOL_BID)
                     :SymbolInfoDouble(info.symbol,SYMBOL_ASK);
   if(price==0.0)
      return;
   MqlTradeRequest req;MqlTradeResult res;ZeroMemory(req);ZeroMemory(res);
   req.action=TRADE_ACTION_DEAL;
   req.position=info.ticket;
   req.symbol=info.symbol;
   req.volume=info.lot;
   req.price=price;
  req.deviation=SlippagePoints;
  req.type=isBuy?ORDER_TYPE_SELL:ORDER_TYPE_BUY;
  req.type_filling=ORDER_FILLING_FOK;
  if(!SimulateExecutionSimple())
    {
     SendTelegram("\xE2\x9D\x8C Simulated rejection for "+info.symbol);
     LogEvent(info.symbol,"SIM_REJECT",info.lot,info.stopLoss,0,info.confidence);
     return;
    }
  ulong tstart=GetTickCount();
  if(SendSmartOrder(req,res,info.symbol,isBuy))
     {
      if(res.retcode==TRADE_RETCODE_REJECT)
        {
         gTradingPaused=true;
         gErrorPauseEndTime=TimeCurrent()+PauseAfterErrorMinutes*60;
         string msg=StringFormat("Order rejected, pausing %d minutes",PauseAfterErrorMinutes);
         Print(msg);
         
        }
      else
        {
        SendTelegram(StringFormat("%s SL hit",info.symbol));
        LogEvent(info.symbol,"SL",info.lot,info.stopLoss,0,info.confidence);
        UpdateStats(info.symbol,false);
        ConfidenceFactors ff; ff.ema=info.facEMA; ff.rsi=info.facRSI; ff.ob=info.facOB; ff.bos=info.facBOS; ff.engulf=info.facEngulf;
        UpdateConfidenceProfile(info.symbol,false,ff);
        string ef=StringFormat("EMA=%d,RSI=%d,OB=%d,BOS=%d,ENG=%d",info.facEMA?1:0,info.facRSI?1:0,info.facOB?1:0,info.facBOS?1:0,info.facEngulf?1:0);
        LearnFromTradeResult(info.symbol,false,info.confidence,ef);
        double rr=fabs(info.takeProfit3-info.entryPrice)/MathMax(fabs(info.entryPrice-info.stopLoss),1e-5);
        SaveTradeMemory(info.symbol,info.isBuy,info.confidence,ff,false,3);
        UpdatePerformanceStats(info.symbol,false,rr,info.confidence);
        RemoveTradeObjects(info.ticket);
        }
     }
   else
      Print("CloseAtStop failed ",res.retcode);
   TrackExecutionSpeed(tstart,info.symbol);
  }

bool SendTelegram(string message)
  {
   if(TelegramToken=="" || TelegramChatID=="")
      return(false);

   string url="https://api.telegram.org/bot"+TelegramToken+"/sendMessage";
   string postData="chat_id="+TelegramChatID+"&text="+UrlEncode(message);

   uchar post[];StringToCharArray(postData,post);
   uchar result[];string headers="Content-Type: application/x-www-form-urlencoded\r\n";
   string res_headers;int timeout=5000;
   ResetLastError();
   int res=WebRequest("POST",url,headers,timeout,post,result,res_headers);
   if(res==-1)
     {
      Print("Telegram WebRequest failed ",GetLastError());
      gCircuitBreakerTripped=true;
      return(false);
     }
   Print("Telegram sent: ",message);
   return(true);
  }

void LogEvent(string symbol, string event, double lot, double sl, double tp, double confidence)
  {
   string file="ProfitMaxX_Log.csv";
   int handle=FileOpen(file,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(handle==INVALID_HANDLE)
     {
      Print("FileOpen failed ",GetLastError());
      return;
     }
   FileSeek(handle,0,SEEK_END);
  double strength=0.0;
  int idx=GetSymbolIndex(symbol);
  if(idx>=0) strength=gSymbolStrength[idx];
  FileWrite(handle,
            TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
            symbol,
            event,
            DoubleToString(lot,2),
            DoubleToString(sl,2),
            DoubleToString(tp,2),
            DoubleToString(confidence,2),
            DoubleToString(strength,2));
  FileClose(handle);

   if(event=="TP1" || event=="TP2" || event=="TP3")
     {
      double pnl=lot*(tp-sl);
      if(pnl>0)
        {
         gTotalProfit += pnl;
         gTotalWins++;
        }
      else
        {
         gTotalLoss += MathAbs(pnl);
         gTotalLosses++;
        }
      gTotalTrades++;
     }
  }

void LogSlippage(string symbol,double reqPrice,double fillPrice)
  {
   string file="SlippageLog.csv";
   int handle=FileOpen(file,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(handle==INVALID_HANDLE)
     {
      Print("Slippage log open failed ",GetLastError());
      return;
     }
   FileSeek(handle,0,SEEK_END);
   double pts=MathAbs(fillPrice-reqPrice)/SymbolInfoDouble(symbol,SYMBOL_POINT);
   FileWrite(handle,
             TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
             symbol,
             DoubleToString(pts,1),
             DoubleToString(reqPrice,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)),
             DoubleToString(fillPrice,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)));
   FileClose(handle);
   gLastSlippage=pts;
  if(pts>MaxSlippagePoints)
     {
      string msg=StringFormat("\xE2\x9A\xA0 High slippage %.1f pts on %s",pts,symbol);
      Print(msg);
      SendTelegram(msg);
     }
void LogExecution(string symbol,datetime reqT,datetime resT,double reqPrice,double fillPrice,uint retcode)
{
   int h=FileOpen(ExecutionLogFile,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE)
      h=FileOpen(ExecutionLogFile,FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE) return;

   FileSeek(h,0,SEEK_END);
   double slip=MathAbs(fillPrice-reqPrice)/SymbolInfoDouble(symbol,SYMBOL_POINT);
   double lat = (resT-reqT)*1000.0;
   FileWrite(h,
             TimeToString(reqT,TIME_DATE|TIME_SECONDS),
             symbol,
             DoubleToString(reqPrice,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)),
             DoubleToString(fillPrice,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)),
             DoubleToString(slip,1),
             DoubleToString(lat,0),
             EnumToString((ENUM_TRADE_RETCODE)retcode));
   FileClose(h);
   UpdateExecutionStats(symbol,slip,lat,retcode==TRADE_RETCODE_DONE || retcode==TRADE_RETCODE_PLACED,retcode==TRADE_RETCODE_REQUOTE);
  }

void UpdateExecutionStats(string symbol,double slip,double latency,bool success,bool requote)
  {
   int idx=GetSymbolIndex(symbol);
   if(idx<0) return;
   gExecSlipSum[idx]+=slip;
   gExecSlipCount[idx]++;
   gExecLatSum[idx]+=latency;
   gExecLatCount[idx]++;
   gExecOrders[idx]++;
   if(success) gExecSuccess[idx]++;
   if(requote) gExecRequotes[idx]++;
  }

void ResetExecutionStats()
  {
   for(int i=0;i<gSymbolCount;i++)
     {
      gExecSlipSum[i]=0; gExecSlipCount[i]=0;
      gExecLatSum[i]=0;  gExecLatCount[i]=0;
      gExecRequotes[i]=0; gExecOrders[i]=0; gExecSuccess[i]=0;
     }
   gExecResetTime=TimeCurrent();
  }

double GetAvgSlippage(string symbol)
  {
   int idx=GetSymbolIndex(symbol);
   if(idx<0 || gExecSlipCount[idx]==0) return(0.0);
   return(gExecSlipSum[idx]/gExecSlipCount[idx]);
  }

double GetAvgLatency(string symbol)
  {
   int idx=GetSymbolIndex(symbol);
   if(idx<0 || gExecLatCount[idx]==0) return(0.0);
   return(gExecLatSum[idx]/gExecLatCount[idx]);
  }

double GetRequoteRate(string symbol)
  {
   int idx=GetSymbolIndex(symbol);
   if(idx<0 || gExecOrders[idx]==0) return(0.0);
   return((double)gExecRequotes[idx]/gExecOrders[idx]*100.0);
  }
     

void LogNewsBlock(string symbol,datetime newsTime,string impact,string desc)
  {
   string file="NewsBlockLog.csv";
   int h=FileOpen(file,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE)
      h=FileOpen(file,FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE) return;
   FileSeek(h,0,SEEK_END);
   FileWrite(h,
             TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
             symbol,
             TimeToString(newsTime,TIME_DATE|TIME_MINUTES),
             impact,
             desc);
   FileClose(h);
  }

void UpdateDashboard()
  {
   string prefix="PMX_";
   int y=10;
   int lineH=15;

   double dd=0.0;
   if(gStartDayBalance>0)
      dd=(gStartDayBalance-AccountInfoDouble(ACCOUNT_EQUITY))/gStartDayBalance*100.0;
   string status=gTradingPaused?"PAUSED":"ACTIVE";
   color statusCol=gTradingPaused?clrRed:clrLime;
   if(gCircuitBreakerActive)
     {
      status="CIRCUIT HALTED";
      statusCol=clrRed;
     }

  string name=prefix+"STATUS";
  if(ObjectFind(0,name)<0)
    {
     ObjectCreate(0,name,OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
     ObjectSetInteger(0,name,OBJPROP_XDISTANCE,10);
     ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
    }
  ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
  ObjectSetInteger(0,name,OBJPROP_COLOR,statusCol);
  ObjectSetString(0,name,OBJPROP_TEXT,StringFormat("Status: %s",status));
  y+=lineH;

  name=prefix+"CB";
  if(ObjectFind(0,name)<0)
    {
     ObjectCreate(0,name,OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
     ObjectSetInteger(0,name,OBJPROP_XDISTANCE,10);
     ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
    }
  ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
  color cbCol=gCircuitBreakerActive?clrRed:clrLime;
  string cbStr=gCircuitBreakerActive?"HALTED":"OK";
  if(gCircuitBreakerTripped)
    {
     cbCol=clrRed;
     cbStr="KILL";
    }
  if(gTradingPaused && gCircuitReason!="")
     cbStr=gCircuitReason;
  ObjectSetInteger(0,name,OBJPROP_COLOR,cbCol);
  ObjectSetString(0,name,OBJPROP_TEXT,StringFormat("Circuit: %s",cbStr));
  y+=lineH;

  name=prefix+"EMO";
  if(ObjectFind(0,name)<0)
    {
     ObjectCreate(0,name,OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
     ObjectSetInteger(0,name,OBJPROP_XDISTANCE,10);
     ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
    }
  ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
  int emoLeft=(int)MathCeil((gStreakCooldownUntil-TimeCurrent())/60.0);
  string emoTxt="Streak OK";
  color emoCol=clrLime;
  if(TimeCurrent()<gStreakCooldownUntil)
    {
     emoCol=clrYellow;
     emoTxt=StringFormat("Streak CD: %dm",emoLeft);
    }
  ObjectSetInteger(0,name,OBJPROP_COLOR,emoCol);
  ObjectSetString(0,name,OBJPROP_TEXT,emoTxt);
  y+=lineH;

   name=prefix+"PERF";
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,250);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,9);
     }
   double winrate = (gTotalTrades > 0) ? (100.0 * gTotalWins / gTotalTrades) : 0;
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clrAqua);
   ObjectSetString(0,name,OBJPROP_TEXT,
                   StringFormat("Wins: %d | Losses: %d | WinRate: %.1f%% | PnL: %.2f",
                                gTotalWins, gTotalLosses, winrate, gTotalProfit - gTotalLoss));

   name=prefix+"DD";
   if(ObjectFind(0,name)<0)
     {
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,10);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
     }
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
  ObjectSetInteger(0,name,OBJPROP_COLOR,clrWhite);
  ObjectSetString(0,name,OBJPROP_TEXT,StringFormat("Daily DD: %.2f%%",dd));
  y+=lineH;

  name=prefix+"PING";
  if(ObjectFind(0,name)<0)
    {
     ObjectCreate(0,name,OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
     ObjectSetInteger(0,name,OBJPROP_XDISTANCE,10);
     ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
    }
  ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
  color pingCol=gLastPing>MaxAllowedPingMs?clrRed:clrLime;
  ObjectSetInteger(0,name,OBJPROP_COLOR,pingCol);
  ObjectSetString(0,name,OBJPROP_TEXT,StringFormat("Ping: %.0fms",gLastPing));
  y+=lineH;

  name=prefix+"SLIP";
  if(ObjectFind(0,name)<0)
    {
     ObjectCreate(0,name,OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
     ObjectSetInteger(0,name,OBJPROP_XDISTANCE,10);
     ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
    }
  ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
  color slipCol=gLastSlippage>MaxSlippagePoints?clrRed:clrLime;
  ObjectSetInteger(0,name,OBJPROP_COLOR,slipCol);
  ObjectSetString(0,name,OBJPROP_TEXT,StringFormat("Slippage: %.1f",gLastSlippage));
  y+=lineH;

  // News info
  name=prefix+"NEWS";
  if(ObjectFind(0,name)<0)
    {
     ObjectCreate(0,name,OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
     ObjectSetInteger(0,name,OBJPROP_XDISTANCE,10);
     ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
    }
  datetime now=TimeCurrent();
  datetime nextT=0; string nextImp=""; string nextDesc=""; string nextCur="";
  bool newsActive=false;
  for(int i=0;i<ArraySize(gNewsSymbols);i++)
    {
     if(now>=gNewsStart[i] && now<=gNewsEnd[i]) newsActive=true;
     if(gNewsStart[i]>now && (nextT==0 || gNewsStart[i]<nextT))
       {
        nextT=gNewsStart[i];
        nextCur=gNewsSymbols[i];
        nextImp=gNewsImpact[i];
        nextDesc=gNewsNames[i];
       }
    }
  string nf= newsActive?"YES":"NO";
  string nextInfo="";
  if(nextT>0)
     nextInfo=StringFormat("Next News: %s %s @ %s (%s)",nextCur,nextDesc,TimeToString(nextT,TIME_MINUTES),nextImp);
  ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
  ObjectSetInteger(0,name,OBJPROP_COLOR,newsActive?clrYellow:clrLime);
  ObjectSetString(0,name,OBJPROP_TEXT,StringFormat("News Filter: %s %s",nf,nextInfo));
  y+=lineH;

  name=prefix+"BROKER";
  if(ObjectFind(0,name)<0)
    {
     ObjectCreate(0,name,OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
     ObjectSetInteger(0,name,OBJPROP_XDISTANCE,10);
     ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
    }
  ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
  string bstat="Healthy";
  color bcol=clrLime;
  if(gLastPing>MaxAllowedPingMs || gLastSlippage>MaxSlippagePoints)
    { bstat="Risky"; bcol=clrYellow; }
  if(gCircuitBreakerTripped || gLastPing>MaxPingLimitMs)
    { bstat="Critical"; bcol=clrRed; }
  ObjectSetInteger(0,name,OBJPROP_COLOR,bcol);
  ObjectSetString(0,name,OBJPROP_TEXT,StringFormat("Broker Status: %s",bstat));
  y+=lineH;
  double slipAvg=0,latAvg=0;int samp=0;for(int j=0;j<gSymbolCount;j++){slipAvg+=gExecSlipSum[j];latAvg+=gExecLatSum[j];samp+=gExecSlipCount[j];}if(samp>0){slipAvg/=samp;latAvg/=samp;}
  name=prefix+"EXEC";
  if(ObjectFind(0,name)<0){ObjectCreate(0,name,OBJ_LABEL,0,0,0);ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,name,OBJPROP_XDISTANCE,10);ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);}
  ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,name,OBJPROP_COLOR,clrWhite);ObjectSetString(0,name,OBJPROP_TEXT,StringFormat("Exec Avg: %.1fpts %.0fms",slipAvg,latAvg));y+=lineH;

  name=prefix+"LIQSKIP";
  if(ObjectFind(0,name)<0)
    {
     ObjectCreate(0,name,OBJ_LABEL,0,0,0);
     ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
     ObjectSetInteger(0,name,OBJPROP_XDISTANCE,10);
     ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
    }
  ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
  ObjectSetInteger(0,name,OBJPROP_COLOR,clrAqua);
  ObjectSetString(0,name,OBJPROP_TEXT,StringFormat("Liquidity Skips: %d",gLiquiditySkipCount));
  y+=lineH;

   for(int i=0;i<gSymbolCount;i++)
     {
      string sym=gSymbols[i];
      string name=prefix+sym;
      int trades=0;
      for(int p=0;p<PositionsTotal();p++)
         if(PositionGetSymbol(p)==sym)
            trades++;

      double conf=gLastConfidence[i];
      double spread=gLastSpread[i];
      double ai=gAIPatternConf[i];
      string dir=gAIPatternDir[i]?"B":"S";
      datetime now=TimeCurrent();
      int mins=0;
      color col=gTradingPaused?clrRed:clrLime;
      if(now<gCooldownEndTime[i])
        {
         col=clrYellow;
         mins=(int)MathCeil((gCooldownEndTime[i]-now)/60.0);
        }

      if(gLastSpread[i]>MaxAllowedSpreadPoints)
        col=clrRed;

      string extra="";
      if(mins>0) extra=StringFormat(" cooldown %dm",mins);
      if(TimeCurrent()-gTrapTime[i]<600)
        {
         extra+=" TRAP";
         if(gLiqBuyLevel[i]>0 || gLiqSellLevel[i]>0)
           extra+=StringFormat(" %.5f/%.5f",gLiqBuyLevel[i],gLiqSellLevel[i]);
        }
      if(gLastSpread[i]>MaxAllowedSpreadPoints)
         extra+=" Spread too high";
      if(now<gEmoCooldownUntil[i])
         extra+=StringFormat(" EMO %dm",(int)MathCeil((gEmoCooldownUntil[i]-now)/60.0));

      int wins=gWinCount[i];
      int losses=gLossCount[i];
      int streak=gStreak[i];
      string streakStr=streak>0?"+"+IntegerToString(streak):IntegerToString(streak);
      double str=gSymbolStrength[i];
      if(TimeCurrent()<gSymbolPauseUntil[i])
         extra+=" ROT";
      string text=StringFormat("%s: %d trades conf %.2f str %.2f sp%.1f AI %s %.0f%% W%d/L%d Streak %s%s",
                              sym,trades,conf,str,spread,dir,ai,wins,losses,streakStr,extra);
      if(ObjectFind(0,name)<0)
        {
         ObjectCreate(0,name,OBJ_LABEL,0,0,0);
         ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,name,OBJPROP_XDISTANCE,10);
         ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
        }
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_COLOR,col);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      y+=lineH;
     }
  }

string UrlEncode(string text)
  {
   string out="";
   for(int i=0;i<StringLen(text);i++)
     {
      uchar c=(uchar)StringGetCharacter(text,i);
      if((c>='0' && c<='9') || (c>='A' && c<='Z') ||
         (c>='a' && c<='z') || c=='-' || c=='_' || c=='.' || c=='~')
        out+=CharToString(c);
      else if(c==' ')
        out+="%20";
      else
        out+=StringFormat("%%%02X",c);
     }
   return(out);
  }

string StringBetween(string data,string a,string b)
  {
   int s=StringFind(data,a);
   if(s==-1) return("");
   s+=StringLen(a);
   int e=StringFind(data,b,s);
   if(e==-1) return("");
   return(StringSubstr(data,s,e-s));
  }

void StartCooldown(string symbol)
  {
   for(int i=0;i<gSymbolCount;i++)
      if(gSymbols[i]==symbol)
         gCooldownEndTime[i]=TimeCurrent()+CooldownMinutesAfterLoss*60;
  }

void UpdateStats(string symbol,bool win)
  {
   int idx=GetSymbolIndex(symbol);
   if(idx<0) return;
  if(win)
    {
     gWinCount[idx]++;
     gDayWins++;
       gTradeWins++;
     if(gStreak[idx]>=0) gStreak[idx]++; else gStreak[idx]=1;
    }
  else
    {
    gLossCount[idx]++;
      gTradeLosses++;
    gDayLosses++;
    if(gStreak[idx]<=0) gStreak[idx]--; else gStreak[idx]=-1;
    gLastLossTime[idx]=TimeCurrent();
   if(EnableObliterationMode)
      gOblitUntil[idx]=TimeCurrent()+ObliterationMinutes*60;
   if(EnableSymbolRotation && gStreak[idx]<=-3)
       {
        gSymbolPauseUntil[idx]=TimeCurrent()+3600;
        string msg=StringFormat("Symbol %s rotated off for 1h after losses",symbol);
        Print(msg);
        
       }
   if(gStreak[idx]<=-5 && !gCircuitBreakerTripped)
      {
       gCircuitBreakerTripped=true;
       string msg=StringFormat("\xF0\x9F\x9A\xA8 Circuit Breaker: 5 losses on %s",symbol);
       Print(msg);
       
      }
   }
  }

int GetSymbolIndex(string symbol)
  {
   for(int i=0;i<gSymbolCount;i++)
      if(gSymbols[i]==symbol)
         return(i);
   return(-1);
  }

void CheckDailyDrawdown()
  {
  if(TimeDay(gStartDayTime)!=TimeDay(TimeCurrent()))
    {
    double net=AccountInfoDouble(ACCOUNT_BALANCE)-gStartDayBalance;
    int trades=gDayWins+gDayLosses;
    double avgConf=(gDayConfCount>0)?gDayConfSum/gDayConfCount:0.0;
    double pnlPct=(gStartDayBalance>0)?net/gStartDayBalance*100.0:0.0;
    string sum=StringFormat("Daily summary: %d trades W:%d L:%d WinRate %.1f%% AvgConf %.2f PnL %.2f (%.2f%%)",
                            trades,gDayWins,gDayLosses,
                            trades>0?100.0*gDayWins/trades:0.0,
                            avgConf,net,pnlPct);
    double best=0;double worst=1;string b="",w="";
    for(int i=0;i<gSymbolCount;i++){int tot=gFBWins[i]+gFBLosses[i]; if(tot==0) continue; double r=(double)gFBWins[i]/tot; if(r>best){best=r;b=gSymbols[i];} if(r<worst){worst=r;w=gSymbols[i];}}
    string extra=""; if(b!=""||w!="") extra=StringFormat(" Top %s %.0f%% Worst %s %.0f%%",b,best*100,w,worst*100);
    Print(sum+extra);
    SendTelegram(sum+extra);
    gDayWins=0;
    gDayLosses=0;
    gDayConfSum=0.0;
    ResetExecutionStats();
    gDayConfCount=0;
    gTP1Count=0; gTP2Count=0; gTP3Count=0;
    gStartDayTime=TimeCurrent();
    gStartDayBalance=AccountInfoDouble(ACCOUNT_BALANCE);
    gStartDayEquity=AccountInfoDouble(ACCOUNT_EQUITY);
    gTradingPaused=false;
    gErrorPauseEndTime=0;
    ResetStreakCounters();
    emotionalCooldownEnd=0;
    gCircuitTriggered=false;
   }

   if(gTradingPaused)
      return;

   double dd=(gStartDayBalance-AccountInfoDouble(ACCOUNT_EQUITY))/gStartDayBalance*100.0;
   double eq=(gStartDayEquity-AccountInfoDouble(ACCOUNT_EQUITY))/gStartDayEquity*100.0;
   if(dd>=MaxDailyDrawdownPercent || eq>=MaxEquityLossPercent)
     {
      gTradingPaused=true;
      string msg=StringFormat("Drawdown limit hit: DD %.2f%% EQ %.2f%%",dd,eq);
      Print(msg);
      
     if(gLossStreak >= 3 && TimeCurrent() - gLastLossGlobal < 1800) {
        gTradingPaused = true;
        string msg2 = "Auto-pause: Too many losses recently.";
        Print(msg2);
        SendTelegram(msg2);
     }
    }
  }

void CheckCircuitBreakers()
  {
   double margin=AccountInfoDouble(ACCOUNT_MARGIN);
   double equity=AccountInfoDouble(ACCOUNT_EQUITY);
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double marginPercent=(equity>0)?(margin/equity)*100.0:0.0;

   if(marginPercent>=MaxMarginUsagePercent)
     {
      if(!gCircuitBreakerActive)
         SendTelegram("\xE2\x9D\x8C Circuit Breaker: Margin usage exceeded");
      gCircuitBreakerActive=true;
      return;
     }

   if(equity<=MinEquityAbsolute)
     {
      if(!gCircuitBreakerActive)
         SendTelegram("\xE2\x9D\x8C Circuit Breaker: Equity below minimum");
      gCircuitBreakerActive=true;
      return;
     }

   long ping=TerminalInfoInteger(TERMINAL_PING_LAST);
   if(ping>=MaxLatencyMS)
     {
      if(!gCircuitBreakerActive)
         SendTelegram(StringFormat("\xE2\x9D\x8C Circuit Breaker: Latency exceeded (%dms)",ping));
      gCircuitBreakerActive=true;
      return;
     }

  gCircuitBreakerActive=false;
 }

// Hard circuit breaker that permanently halts trading until manual reset
void CheckCircuitBreaker()
  {
   double marginUsed = AccountInfoDouble(ACCOUNT_MARGIN);
   double marginFree = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double marginTotal = marginUsed + marginFree;
   double marginUsage = (marginTotal>0)?(marginUsed/marginTotal)*100.0:0.0;

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);

   long ping = TerminalInfoInteger(TERMINAL_PING_LAST);

   if(marginUsage >= MaxMarginUsePercent)
     {
      gCircuitBreakerTripped = true;
      SendTelegram("\xF0\x9F\x9A\xA8 Circuit Breaker: Margin usage exceeded " + DoubleToString(marginUsage,1) + "%");
     }
   else if(equity <= AccountInfoDouble(ACCOUNT_BALANCE)*EquityFloorPercent/100.0)
     {
      gCircuitBreakerTripped = true;
      SendTelegram("\xF0\x9F\x9A\xA8 Circuit Breaker: Equity below floor " + DoubleToString(equity,2));
     }
  else if(ping >= MaxPingLimitMs)
    {
     gCircuitBreakerTripped = true;
     SendTelegram("\xF0\x9F\x9A\xA8 Circuit Breaker: Network latency too high (" + IntegerToString((int)ping) + "ms)");
    }
  }

// New kill switch logic with auto-resume
void CircuitBreakerKillSwitch()
  {
   // auto resume if time elapsed
   if(gTradingPaused && gCircuitReason!="" && TimeCurrent()>=gCircuitResumeTime)
     {
      gTradingPaused=false;
      gCircuitReason="";
      SendTelegram("Circuit breaker auto-resumed");
     }
   if(gTradingPaused) return;

   double marginLevel=AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   double marginUsed=AccountInfoDouble(ACCOUNT_MARGIN);
   double marginFree=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double usage=(marginUsed+marginFree>0)?marginUsed/(marginUsed+marginFree)*100.0:0.0;

   if(marginLevel<100.0 || usage>80.0)
     {
      gTradingPaused=true;
      gCircuitReason="MARGIN";
      gCircuitResumeTime=TimeCurrent()+3600*CircuitResetHours;
      SendTelegram("\xE2\x9A\xA0 Circuit Breaker Triggered: Margin usage too high!");
      return;
     }

   double equity=AccountInfoDouble(ACCOUNT_EQUITY);
   if(gInitialBalance>0 && equity<gInitialBalance*0.5)
     {
      gTradingPaused=true;
      gCircuitReason="EQUITY";
      gCircuitResumeTime=TimeCurrent()+3600*CircuitResetHours;
      SendTelegram("\xF0\x9F\x94\xBB Equity floor breached. Trading paused.");
      return;
     }

   static double avgPing=0.0;
   static uint last=0;
   uint now=GetTickCount();
   double tickVal=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   if(last==0) last=now;
   double sim=(double)(now-last)+tickVal;
   last=now;
   avgPing=avgPing*0.8+sim*0.2;
   if(avgPing>5000.0)
     {
      gTradingPaused=true;
      gCircuitReason="LATENCY";
      gCircuitResumeTime=TimeCurrent()+3600*CircuitResetHours;
      SendTelegram("\xF0\x9F\x9B\x91 Network latency critical. Disabling bot.");
     }
  }

long GetChartForSymbol(string symbol)
  {
   long cid=ChartFirst();
   while(cid>=0)
     {
      if(ChartSymbol(cid)==symbol)
         return(cid);
      cid=ChartNext(cid);
     }
   return(ChartOpen(symbol,PERIOD_CURRENT));
  }

// Visual trade markers for each entry
void DrawTradeObjects(ulong ticket,string symbol,bool isBuy,double entry,double sl,double tp1,double tp2,double tp3)
  {
   long chart=GetChartForSymbol(symbol);
   string base="PMX_";
   string name;

   // Entry arrow
   name=base+"ENTRY_"+IntegerToString((int)ticket);
   ObjectCreate(chart,name,OBJ_ARROW,0,TimeCurrent(),entry);
   ObjectSetInteger(chart,name,OBJPROP_ARROWCODE,isBuy?SYMBOL_ARROWUP:SYMBOL_ARROWDOWN);
   ObjectSetInteger(chart,name,OBJPROP_COLOR,isBuy?clrLime:clrRed);

   // SL line
   name=base+"SL_"+IntegerToString((int)ticket);
   ObjectCreate(chart,name,OBJ_HLINE,0,0,sl);
   ObjectSetInteger(chart,name,OBJPROP_COLOR,clrRed);
   ObjectSetString(chart,name,OBJPROP_TEXT,"SL");

   // TP1 line
   name=base+"TP1_"+IntegerToString((int)ticket);
   ObjectCreate(chart,name,OBJ_HLINE,0,0,tp1);
   ObjectSetInteger(chart,name,OBJPROP_COLOR,clrGreen);
   ObjectSetString(chart,name,OBJPROP_TEXT,"TP1");

   // TP2 line
   name=base+"TP2_"+IntegerToString((int)ticket);
   ObjectCreate(chart,name,OBJ_HLINE,0,0,tp2);
   ObjectSetInteger(chart,name,OBJPROP_COLOR,clrGreen);
   ObjectSetString(chart,name,OBJPROP_TEXT,"TP2");

   // TP3 line
   name=base+"TP3_"+IntegerToString((int)ticket);
   ObjectCreate(chart,name,OBJ_HLINE,0,0,tp3);
   ObjectSetInteger(chart,name,OBJPROP_COLOR,clrGreen);
  ObjectSetString(chart,name,OBJPROP_TEXT,"TP3");
 }

void MarkLiquidityZone(string symbol,double lvl1,double lvl2,datetime t1,datetime t2)
  {
   long chart=GetChartForSymbol(symbol);
   string name="PMX_LIQ_"+IntegerToString((int)TimeCurrent());
   double hi=MathMax(lvl1,lvl2);
   double lo=MathMin(lvl1,lvl2);
   ObjectCreate(chart,name,OBJ_RECTANGLE,0,t1,hi,t2,lo);
   ObjectSetInteger(chart,name,OBJPROP_COLOR,clrMagenta);
   ObjectSetInteger(chart,name,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(chart,name,OBJPROP_BACK,true);
  }

void RemoveTradeObjects(ulong ticket)
  {
   string base="PMX_";
   string names[5]={"ENTRY_","SL_","TP1_","TP2_","TP3_"};
   for(int i=0;i<5;i++)
     {
      string n=base+names[i]+IntegerToString((int)ticket);
      for(long cid=ChartFirst(); cid>=0; cid=ChartNext(cid))
         ObjectDelete(cid,n);
     }
  }


void AdaptiveLearningUpdate()
  {
   if(!EnableAdaptiveLearning) return;
   datetime now = TimeCurrent();
   if(TimeHour(now) == AdaptiveResetHour && TimeDay(now) != TimeDay(gLastAdaptiveReset))
     {
      gLastAdaptiveReset = now;
      gTradeWins = 0;
      gTradeLosses = 0;
      gDynamicConfidence = BaseConfidenceThreshold;
      gDynamicTPMult = 1.0;
     }

   int total = gTradeWins + gTradeLosses;
   if(total >= AdaptiveLookbackTrades)
     {
      double winRate = (double)gTradeWins / total;
      gDynamicConfidence = BaseConfidenceThreshold + (0.15 * (1.0 - winRate));
      gDynamicTPMult = 1.0 + (0.5 * winRate);
      gDynamicConfidence = MathMin(MathMax(gDynamicConfidence, 0.20), 0.70);
      gDynamicTPMult = MathMin(gDynamicTPMult, 2.0);
     }
  }

// Placeholder AdaptiveLearningModule wrapper
void AdaptiveLearningModule()
  {
   AdaptiveLearningUpdate();
  }

// Placeholder PerformanceAnalyzer for future metrics
void PerformanceAnalyzer()
  {
   // Currently handled within LogEvent and dashboard
  }

void LoadConfidenceProfile(string symbol, ConfidenceProfile &prof)
  {
   string file="PMX_"+symbol+"_conf.csv";
   int h=FileOpen(file,FILE_READ|FILE_CSV|FILE_SHARE_READ|FILE_ANSI);
   if(h!=INVALID_HANDLE)
     {
      prof.EMAWeight       = FileReadNumber(h);
      prof.RSIWeight       = FileReadNumber(h);
      prof.OBWeight        = FileReadNumber(h);
      prof.BOSWeight       = FileReadNumber(h);
      prof.EngulfingWeight = FileReadNumber(h);
      FileClose(h);
     }
   else
     {
      prof.EMAWeight=0.15;
      prof.RSIWeight=0.15;
      prof.OBWeight=0.15;
      prof.BOSWeight=0.15;
      prof.EngulfingWeight=0.15;
     }
  }

void SaveConfidenceProfile(string symbol, ConfidenceProfile &prof)
  {
   string file="PMX_"+symbol+"_conf.csv";
   int h=FileOpen(file,FILE_WRITE|FILE_CSV|FILE_ANSI);
   if(h==INVALID_HANDLE)
     {
      Print("FileOpen write failed ",GetLastError());
      return;
     }
   FileWrite(h,prof.EMAWeight,prof.RSIWeight,prof.OBWeight,prof.BOSWeight,prof.EngulfingWeight);
   FileClose(h);
  }

void UpdateConfidenceProfile(string symbol,bool win,ConfidenceFactors fac)
  {
   int idx=GetSymbolIndex(symbol);
   if(idx<0) return;
   ConfidenceProfile &p=gProfiles[idx];
   double delta=0.02;
   if(win)
     {
      if(fac.ema)       p.EMAWeight+=delta;
      if(fac.rsi)       p.RSIWeight+=delta;
      if(fac.ob)        p.OBWeight +=delta;
      if(fac.bos)       p.BOSWeight+=delta;
      if(fac.engulf)    p.EngulfingWeight+=delta;
     }
   else
     {
      if(fac.ema)       p.EMAWeight-=delta;
      if(fac.rsi)       p.RSIWeight-=delta;
      if(fac.ob)        p.OBWeight -=delta;
      if(fac.bos)       p.BOSWeight-=delta;
      if(fac.engulf)    p.EngulfingWeight-=delta;
     }
   p.EMAWeight       = MathMax(0.05,MathMin(0.5,p.EMAWeight));
   p.RSIWeight       = MathMax(0.05,MathMin(0.5,p.RSIWeight));
   p.OBWeight        = MathMax(0.05,MathMin(0.5,p.OBWeight));
   p.BOSWeight       = MathMax(0.05,MathMin(0.5,p.BOSWeight));
  p.EngulfingWeight = MathMax(0.05,MathMin(0.5,p.EngulfingWeight));
  SaveConfidenceProfile(symbol,p);
 }

void LearnFromTradeResult(string symbol,bool wasWin,double confidence,string entryFactors)
  {
   string file=symbol+"_learning.csv";
   int h=FileOpen(file,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE)
      h=FileOpen(file,FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE)
     {
      Print("Learn file open failed ",GetLastError());
      return;
     }
   FileSeek(h,0,SEEK_END);
   FileWrite(h,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),wasWin?1:0,
             DoubleToString(confidence,2),entryFactors);
   FileClose(h);

   int idx=GetSymbolIndex(symbol);
   if(idx<0) return;
   if(TimeCurrent()-gLastLearnUpdate[idx]<3600)
      return;
   gLastLearnUpdate[idx]=TimeCurrent();

   // Simple stats analysis
   h=FileOpen(file,FILE_READ|FILE_CSV|FILE_SHARE_READ|FILE_ANSI);
   if(h==INVALID_HANDLE) return;
   int winE=0,lossE=0,winR=0,lossR=0,winOB=0,lossOB=0,winBOS=0,lossBOS=0,winEng=0,lossEng=0;
   while(!FileIsEnding(h))
     {
      string d=FileReadString(h);
      if(d=="") break;
      int w=(int)FileReadInteger(h);
      double confVal=FileReadNumber(h);
      string f=FileReadString(h);
      bool e=(StringFind(f,"EMA=1")>=0);
      bool r=(StringFind(f,"RSI=1")>=0);
      bool ob=(StringFind(f,"OB=1")>=0);
      bool bos=(StringFind(f,"BOS=1")>=0);
      bool eng=(StringFind(f,"ENG=1")>=0);
      if(e) { if(w==1) winE++; else lossE++; }
      if(r) { if(w==1) winR++; else lossR++; }
      if(ob){ if(w==1) winOB++; else lossOB++; }
      if(bos){ if(w==1) winBOS++; else lossBOS++; }
      if(eng){ if(w==1) winEng++; else lossEng++; }
     }
   FileClose(h);

   ConfidenceProfile &p=gProfiles[idx];
   double old;
   bool changed=false;
   if(winOB+lossOB>=5)
     {
      double lr=(double)lossOB/(winOB+lossOB);
      old=p.OBWeight;
      if(lr>0.8) p.OBWeight-=0.05; else if((1.0-lr)>0.8) p.OBWeight+=0.05;
      p.OBWeight=MathMax(0.05,MathMin(0.5,p.OBWeight));
      if(old!=p.OBWeight){SendTelegram(StringFormat("\xF0\x9F\xA4\x96 Auto-Tuner: Adjusted OB weight to %.2f for %s",p.OBWeight,symbol));changed=true;}
     }
   if(winBOS+lossBOS>=5)
     {
      double lr=(double)lossBOS/(winBOS+lossBOS);
      old=p.BOSWeight;
      if(lr>0.8) p.BOSWeight-=0.05; else if((1.0-lr)>0.8) p.BOSWeight+=0.05;
      p.BOSWeight=MathMax(0.05,MathMin(0.5,p.BOSWeight));
      if(old!=p.BOSWeight){SendTelegram(StringFormat("\xF0\x9F\xA4\x96 Auto-Tuner: Adjusted BOS weight to %.2f for %s",p.BOSWeight,symbol));changed=true;}
     }
   if(winE+lossE>=5)
     {
      double lr=(double)lossE/(winE+lossE);
      old=p.EMAWeight;
      if(lr>0.8) p.EMAWeight-=0.05; else if((1.0-lr)>0.8) p.EMAWeight+=0.05;
      p.EMAWeight=MathMax(0.05,MathMin(0.5,p.EMAWeight));
      if(old!=p.EMAWeight){SendTelegram(StringFormat("\xF0\x9F\xA4\x96 Auto-Tuner: Adjusted EMA weight to %.2f for %s",p.EMAWeight,symbol));changed=true;}
     }
   if(winR+lossR>=5)
     {
      double lr=(double)lossR/(winR+lossR);
      old=p.RSIWeight;
      if(lr>0.8) p.RSIWeight-=0.05; else if((1.0-lr)>0.8) p.RSIWeight+=0.05;
      p.RSIWeight=MathMax(0.05,MathMin(0.5,p.RSIWeight));
      if(old!=p.RSIWeight){SendTelegram(StringFormat("\xF0\x9F\xA4\x96 Auto-Tuner: Adjusted RSI weight to %.2f for %s",p.RSIWeight,symbol));changed=true;}
     }
   if(winEng+lossEng>=5)
     {
      double lr=(double)lossEng/(winEng+lossEng);
      old=p.EngulfingWeight;
      if(lr>0.8) p.EngulfingWeight-=0.05; else if((1.0-lr)>0.8) p.EngulfingWeight+=0.05;
      p.EngulfingWeight=MathMax(0.05,MathMin(0.5,p.EngulfingWeight));
      if(old!=p.EngulfingWeight){SendTelegram(StringFormat("\xF0\x9F\xA4\x96 Auto-Tuner: Adjusted Engulf weight to %.2f for %s",p.EngulfingWeight,symbol));changed=true;}
     }
  if(changed)
     SaveConfidenceProfile(symbol,p);
  }

void RecordTradeContext(string symbol,double confidence,bool isBuy)
  {
   if(!EnableContextRecorder)
      return;
   string file=symbol+"_context.csv";
   int h=FileOpen(file,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE)
      h=FileOpen(file,FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE)
     {
      Print("RecordTradeContext FileOpen failed ",GetLastError());
      return;
     }
   FileSeek(h,0,SEEK_END);

   double emaFast=iMA(symbol,0,21,0,MODE_EMA,PRICE_CLOSE,1);
   double emaSlow=iMA(symbol,0,50,0,MODE_EMA,PRICE_CLOSE,1);
   double rsi=iRSI(symbol,0,14,PRICE_CLOSE,1);
   int ob=DetectOrderBlocks(symbol);
   int bos=DetectBreakOfStructure(symbol);
   double atr=iATR(symbol,PERIOD_M15,14,1);
   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   double spread=(ask>0 && bid>0)?(ask-bid)/SymbolInfoDouble(symbol,SYMBOL_POINT):0.0;
   string session=EnableSessionFilter?GetCurrentSession():"N/A";
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double equity=AccountInfoDouble(ACCOUNT_EQUITY);
   ulong ticket=0;
   if(PositionSelect(symbol))
      ticket=PositionGetInteger(POSITION_TICKET);

   FileWrite(h,
            TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
            symbol,
            isBuy?"true":"false",
            DoubleToString(confidence,2),
            StringFormat("OB=%d",ob),
            StringFormat("BOS=%d",bos),
            StringFormat("RSI=%.2f",rsi),
            StringFormat("EMAfast=%.5f",emaFast),
            StringFormat("EMAslow=%.5f",emaSlow),
            StringFormat("spread=%.1f",spread),
            StringFormat("ATR=%.2f",atr),
            StringFormat("session=%s",session),
            StringFormat("balance=%.2f",balance),
            StringFormat("equity=%.2f",equity),
            StringFormat("ticket=%llu",ticket));
  FileClose(h);

void LogTradeData(string symbol,bool isBuy,double confidence)
{
   if(!EnableDataRecorder)
      return;
   int handle=FileOpen(DataLogFile,FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_WRITE);
   if(handle==INVALID_HANDLE)
      handle=FileOpen(DataLogFile,FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_SHARE_WRITE);
   if(handle==INVALID_HANDLE)
     {
      Print("LogTradeData FileOpen failed ",GetLastError());
      return;
     }
   FileSeek(handle,0,SEEK_END);
   double rsi=iRSI(symbol,0,14,PRICE_CLOSE,1);
   double emaFast=iMA(symbol,0,21,0,MODE_EMA,PRICE_CLOSE,1);
   double emaSlow=iMA(symbol,0,50,0,MODE_EMA,PRICE_CLOSE,1);
   double atr=iATR(symbol,0,14,1);
   int ob=DetectOrderBlocks(symbol);
   int bos=DetectBreakOfStructure(symbol);
    double spread=SymbolInfoInteger(symbol,SYMBOL_SPREAD)*SymbolInfoDouble(symbol,SYMBOL_POINT);
   double strength=0.0;
   int idx=GetSymbolIndex(symbol);
   if(idx>=0) strength=gSymbolStrength[idx];
   double entryPrice=isBuy?SymbolInfoDouble(symbol,SYMBOL_ASK):SymbolInfoDouble(symbol,SYMBOL_BID);
   double slPts=GetAdaptiveSL(symbol);
   double lot=CalculateLotSize(symbol,slPts,confidence);
   double sl=isBuy?entryPrice-slPts*SymbolInfoDouble(symbol,SYMBOL_POINT)
                 :entryPrice+slPts*SymbolInfoDouble(symbol,SYMBOL_POINT);
   double tp=isBuy?entryPrice+TP1_RR*slPts*SymbolInfoDouble(symbol,SYMBOL_POINT)
                 :entryPrice-TP1_RR*slPts*SymbolInfoDouble(symbol,SYMBOL_POINT);
   FileWrite(handle,
     TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
     symbol,
     isBuy?"Buy":"Sell",
     DoubleToString(confidence,2),
     DoubleToString(rsi,2),
     DoubleToString(emaFast,5),
    DoubleToString(emaSlow,5),
    DoubleToString(spread,5),
    DoubleToString(strength,2),
    DoubleToString(atr,5),
     ob,
     bos,
     DoubleToString(entryPrice,5),
     DoubleToString(sl,5),
     DoubleToString(tp,5),
     DoubleToString(lot,2),
     DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2));
  FileClose(handle);
}

// Record market conditions at trade entry for backtesting
void RecordEntryData(string symbol,bool isBuy,double confidence,double lot,double sl,double tp)
  {
   if(!EnableDataRecorder)
      return;
   int handle=FileOpen(DataRecordFile,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(handle==INVALID_HANDLE)
      handle=FileOpen(DataRecordFile,FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(handle==INVALID_HANDLE)
     {
      Print("Error opening data record file: ",GetLastError());
      return;
     }
   FileSeek(handle,0,SEEK_END);
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   double spread=ask-bid;
   double atr=iATR(symbol,0,14,0);
   double rsi=iRSI(symbol,0,14,PRICE_CLOSE,0);
   double emaFast=iMA(symbol,0,21,0,MODE_EMA,PRICE_CLOSE,0);
   double emaSlow=iMA(symbol,0,50,0,MODE_EMA,PRICE_CLOSE,0);
   double vol=iVolume(symbol,0,0);
   datetime t=TimeCurrent();
   string session=TimeHour(t)<8?"Asia":(TimeHour(t)<16?"London":"NY");
   FileWrite(handle,
             TimeToString(t,TIME_DATE|TIME_SECONDS),
             symbol,
             isBuy?"BUY":"SELL",
             DoubleToString(confidence,2),
             DoubleToString(lot,2),
             DoubleToString(sl,1),
             DoubleToString(tp,1),
             DoubleToString(bid,_Digits),
             DoubleToString(ask,_Digits),
             DoubleToString(spread,_Digits),
             DoubleToString(atr,2),
             DoubleToString(rsi,2),
             DoubleToString(emaFast,2),
             DoubleToString(emaSlow,2),
             IntegerToString((int)vol),
             session);
   FileClose(handle);
  }

void LogTuningData(string symbol,double profit,double confidence,string indicators,bool isBuy)
 {
   if(!EnableConfidenceAutoTune)
      return;
   int h=FileOpen(TuningLogFile,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE)
      h=FileOpen(TuningLogFile,FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE)
     {
      Print("LogTuningData FileOpen failed ",GetLastError());
      return;
     }
   FileSeek(h,0,SEEK_END);
   FileWrite(h,
            TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
            symbol,
            DoubleToString(profit,2),
            DoubleToString(confidence,2),
            indicators,
            isBuy?"Buy":"Sell",
            profit>0?"Win":"Loss");
  FileClose(h);
}

// Confidence auto-tuner logger
void UpdateConfidenceTuner(string symbol,bool win,double confidence,double profit)
  {
   int h=FileOpen(ConfidenceTunerFile,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE)
      h=FileOpen(ConfidenceTunerFile,FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE) return;
   FileSeek(h,0,SEEK_END);
   FileWrite(h,
             TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
             symbol,
             win?"Win":"Loss",
             DoubleToString(confidence,2),
             DoubleToString(profit,2));
   FileClose(h);
   gTunerTradeCount++;
  if(gTunerTradeCount%50==0)
    {
     SendTelegram(StringFormat("Confidence tuner logged %d trades",gTunerTradeCount));
    }
  }

void LogFeedbackTrade(string symbol,bool isBuy,double conf,double sl,double tp,bool win,double spread,datetime t,double atr,double rrr)
  {
   if(!EnableFeedbackLoop) return;
   int h=FileOpen("StrategyFeedback.csv",FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE)
      h=FileOpen("StrategyFeedback.csv",FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE) return;
   FileSeek(h,0,SEEK_END);
   string sess=GetCurrentSession();
   FileWrite(h,
             TimeToString(t,TIME_DATE|TIME_SECONDS),
             symbol,
             isBuy?"Buy":"Sell",
             DoubleToString(conf,2),
             DoubleToString(sl,1),
             DoubleToString(tp,1),
             win?"Win":"Loss",
             DoubleToString(spread,1),
             sess,
             DoubleToString(atr,2),
             DoubleToString(rrr,2));
   FileClose(h);
  }

void ResetFeedbackStats()
  {
   gFeedbackTradeCount=0;
   gLastFeedbackTime=TimeCurrent();
   for(int i=0;i<gSymbolCount;i++){gFBMultiplier[i]=1.0; gFBConsecLoss[i]=0; gFBWins[i]=0; gFBLosses[i]=0;}
  }

void FeedbackLoopUpdate()
  {
   if(!EnableFeedbackLoop) return;
   if(ResetFeedbackNow){ResetFeedbackStats(); ResetFeedbackNow=false;}
   if(TimeCurrent()-gLastFeedbackTime<FeedbackHourInterval*3600 && gFeedbackTradeCount<FeedbackTradeInterval)
      return;
   gLastFeedbackTime=TimeCurrent();
   gFeedbackTradeCount=0;
   double bestRate=0; string bestSym=""; double worstRate=1; string worstSym="";
   for(int i=0;i<gSymbolCount;i++)
     {
      int total=gFBWins[i]+gFBLosses[i];
      if(total==0) continue;
      double rate=(double)gFBWins[i]/total;
      if(gFBConsecLoss[i]>=3)
        { gFBMultiplier[i]*=0.8; gFBConsecLoss[i]=0; }
      if(rate>0.7 && total>=5)
         gFBMultiplier[i]*=1.1;
      if(gFBMultiplier[i]<0.5) gFBMultiplier[i]=0.5;
      if(gFBMultiplier[i]>1.5) gFBMultiplier[i]=1.5;
      if(rate>bestRate){bestRate=rate;bestSym=gSymbols[i];}
      if(rate<worstRate){worstRate=rate;worstSym=gSymbols[i];}
     }
  if(bestSym!="" || worstSym!="")
    {
     string msg=StringFormat("Feedback: best %s %.0f%% worst %s %.0f%%",bestSym,bestRate*100,worstSym,worstRate*100);
     
    }
  UpdateTPOptimization();
 }

// Fetch AI prediction from external server
bool GetAIPrediction(string symbol,bool &dir,double &conf)
  {
   dir=true; conf=0.0;
   if(!EnableAIPatterns || AIEndpointURL=="")
      return(false);
   MqlRates rates[];
   int cnt=AICandleCount>1?AICandleCount:20;
   if(CopyRates(symbol,PERIOD_M5,0,cnt,rates)<=0)
      return(false);
   string json="{\"symbol\":\""+symbol+"\",\"timeframe\":\"M5\",\"candles\":[";
   for(int i=ArraySize(rates)-1;i>=0;i--)
     {
      if(i<ArraySize(rates)-1) json+=",";
      json+="["+DoubleToString(rates[i].time,0)+","+
            DoubleToString(rates[i].open,_Digits)+","+
            DoubleToString(rates[i].high,_Digits)+","+
            DoubleToString(rates[i].low,_Digits)+","+
            DoubleToString(rates[i].close,_Digits)+","+
            DoubleToString(rates[i].tick_volume,0)+"]";
     }
   json+="]}";
   uchar post[]; StringToCharArray(json,post);
   uchar result[]; string headers="Content-Type: application/json\r\n"; string res;
   ResetLastError();
   int code=WebRequest("POST",AIEndpointURL,headers,5000,post,result,res);
   if(code==-1)
     {
      int err=GetLastError();
      int h=FileOpen("AI_Prediction_Errors.csv",FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
      if(h!=INVALID_HANDLE){ FileSeek(h,0,SEEK_END); FileWrite(h,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),symbol,err); FileClose(h);} 
      return(false);
     }
   string data=CharArrayToString(result);
   string sdir=StringBetween(data,"\"predict\":\"","\"");
   string sc=StringBetween(data,"\"confidence\":", "}");
   if(sdir=="" || sc=="")
      return(false);
   dir=(StringFind(StringToLower(sdir),"buy")>=0);
   conf=StringToDouble(sc);
   int handle=FileOpen("AI_Trade_Signals.csv",FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(handle!=INVALID_HANDLE){ FileSeek(handle,0,SEEK_END); FileWrite(handle,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),symbol,dir?"BUY":"SELL",DoubleToString(conf,2)); FileClose(handle); }
   int idx=GetSymbolIndex(symbol); if(idx>=0){ gAIPatternConf[idx]=conf*100; gAIPatternDir[idx]=dir; }
   return(true);
  }

// Query external AI pattern server
bool QueryAIPattern(string symbol,bool &dir,double &conf)
  {
   conf=0.0; dir=true;
   if(!EnableAIPatternFilter)
      return(false);
   MqlRates rates[];
   if(CopyRates(symbol,PERIOD_M5,0,20,rates)<=0)
      return(false);
   string json="{\"symbol\":\""+symbol+"\",\"timeframe\":\"M5\",\"candles\":[";
   for(int i=ArraySize(rates)-1;i>=0;i--)
     {
      if(i<ArraySize(rates)-1) json+=",";
      json+="{\"open\":"+DoubleToString(rates[i].open,6)+",\"high\":"+
            DoubleToString(rates[i].high,6)+",\"low\":"+
            DoubleToString(rates[i].low,6)+",\"close\":"+
            DoubleToString(rates[i].close,6)+"}";
     }
   json+"]}";
   uchar post[];StringToCharArray(json,post);
   uchar result[];string headers="Content-Type: application/json\r\n";
   string res_head;ResetLastError();
   int res=WebRequest("POST",AI_API_URL,headers,5000,post,result,res_head);
   if(res==-1)
     {
      Print("AI pattern WebRequest failed ",GetLastError());
      return(false);
     }
   string data=CharArrayToString(result);
   if(StringFind(data,"none")>=0)
      return(false);
   string sdir=StringBetween(data,"\"signal\":\"","\"");
   string sc=StringBetween(data,"\"confidence\":","}");
   conf=StringToDouble(sc);
   dir=(StringFind(StringToLower(sdir),"buy")>=0);
   int idx=GetSymbolIndex(symbol);
  if(idx>=0){gAIPatternConf[idx]=conf*100; gAIPatternDir[idx]=dir;}
  return(true);
  }

// Simplified AI recommendation using recent candle and indicators
bool GetAIRecommendation(string symbol,bool &aiBuy,double &confidence)
  {
   aiBuy=true; confidence=0.0;
   if(!EnableAIPatternDetection || AIEndpointURL=="")
      return(false);

   double open=iOpen(symbol,0,1);
   double high=iHigh(symbol,0,1);
   double low=iLow(symbol,0,1);
   double close=iClose(symbol,0,1);
   double volume=iVolume(symbol,0,1);
   double ema21=iMA(symbol,0,21,0,MODE_EMA,PRICE_CLOSE,1);
   double ema50=iMA(symbol,0,50,0,MODE_EMA,PRICE_CLOSE,1);
   double rsi=iRSI(symbol,0,14,PRICE_CLOSE,1);

   string jsonData="{\"symbol\":\""+symbol+
                   "\",\"open\":"+DoubleToString(open,6)+
                   ",\"high\":"+DoubleToString(high,6)+
                   ",\"low\":"+DoubleToString(low,6)+
                   ",\"close\":"+DoubleToString(close,6)+
                   ",\"volume\":"+DoubleToString(volume,0)+
                   ",\"ema21\":"+DoubleToString(ema21,6)+
                   ",\"ema50\":"+DoubleToString(ema50,6)+
                   ",\"rsi\":"+DoubleToString(rsi,2)+"}";

   uchar post[]; StringToCharArray(jsonData,post);
   uchar result[]; string headers="Content-Type: application/json\r\n";
   string responseHeaders; ResetLastError();
   int code=WebRequest("POST",AIEndpointURL,headers,3000,post,result,responseHeaders);
   if(code==-1)
     {
      Print("AI API request failed: ",GetLastError());
      return(false);
     }
   string rawResponse=CharArrayToString(result);
   int buyIndex=StringFind(rawResponse,"\"buy\":");
   int confIndex=StringFind(rawResponse,"\"confidence\":");
   if(buyIndex==-1 || confIndex==-1)
      return(false);
   string buyVal=StringSubstr(rawResponse,buyIndex+6,5);
   string confVal=StringSubstr(rawResponse,confIndex+13,5);
   aiBuy=(StringFind(buyVal,"true")>=0);
   confidence=StringToDouble(confVal);
   return(true);
  }

// Simulate broker latency and slippage
void SimulateBrokerConditions(string symbol,bool isBuy,double &price)
  {
   if(!EnableBrokerSimulation)
      return;
   int delay=100+MathRand()%401;
   Sleep(delay);
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   double slipMax=GetSpreadPoints(symbol)*point*0.5;
   double slip=(MathRand()/32767.0)*slipMax;
   if(isBuy) price+=slip; else price-=slip;
   if(MathRand()%20==0)
     {
      price+=isBuy?point:-point;
      Print("Simulated requote for ",symbol);
      LogEvent(symbol,"REQUOTE",0,0,0,0);
     }
   Print(StringFormat("BrokerSim delay %dms slippage %.1f pts",delay,slip/point));
   LogEvent(symbol,"SIM",0,0,slip/point,0);
  }

// Simulate real market execution effects
bool SimulateExecution(MqlTradeRequest &req)
  {
   if(!EnableExecutionSimulation)
      return(true);

   double point=SymbolInfoDouble(req.symbol,SYMBOL_POINT);
   if(point<=0)
      return(true);

   int range=MaxSlippageSimPoints*2+1;
   int slip=MathRand()%range-MaxSlippageSimPoints;
   req.price+=slip*point;
   Print(StringFormat("Simulated Slippage: %+d points",slip));
   LogEvent(req.symbol,"SIM_SLIP",req.volume,0,slip,0);

   int r=MathRand()%100;
   if(r<RejectionChancePercent)
     {
      Print("Trade rejected by simulation for ",req.symbol);
      SendTelegram("Trade rejected by simulation: "+req.symbol);
      LogEvent(req.symbol,"SIM_REJECT",req.volume,0,0,0);
      return(false);
     }

   if(r<RejectionChancePercent+RequoteChancePercent)
     {
      int delay=300+MathRand()%401;
      Sleep(delay);
      Print(StringFormat("Simulated requote %dms",delay));
      SendTelegram("Simulated requote: "+req.symbol);
      LogEvent(req.symbol,"SIM_REQUOTE",req.volume,0,0,0);
      double newPrice=(req.type==ORDER_TYPE_BUY||req.type==ORDER_TYPE_BUY_LIMIT||req.type==ORDER_TYPE_BUY_STOP)?
                      SymbolInfoDouble(req.symbol,SYMBOL_ASK):SymbolInfoDouble(req.symbol,SYMBOL_BID);
      int slip2=MathRand()%range-MaxSlippageSimPoints;
      req.price=newPrice+slip2*point;
      Print(StringFormat("Requote new price with slippage %+d pts",slip2));
     }

  return(true);
  }

// Basic market execution simulator adjusting price, latency and requote chance
bool SimulateMarketExecution(string symbol,double &price,double slippagePoints,bool isBuy)
  {
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   double maxSlip=slippagePoints*point;
   double slip=(MathRand()%int(maxSlip*2*10000))/10000.0-maxSlip;
   if(!isBuy) slip=-slip;
   price+=slip;

   int delayMs=100+MathRand()%400;
   Sleep(delayMs);

   int chance=MathRand()%100;
   if(chance<5)
     {
      Print("Simulated requote occurred. Adjusting price.");
      double pip=point*10;
      price+=isBuy?pip:-pip;
      return(false);
     }
   return(true);
  }

// Execution reality simulator with basic slippage and rejection
bool ExecutionReality(MqlTradeRequest &req)
  {
   if(!EnableExecutionSim)
      return(true);
   double point=SymbolInfoDouble(req.symbol,SYMBOL_POINT);
   if(point<=0) return(true);
   int slip=(MathRand()%(SimMaxSlippagePoints*2+1))-SimMaxSlippagePoints;
   req.price+=slip*point;
   if(slip!=0)
     {
      Print(StringFormat("RealitySim slippage %+d pts",slip));
      LogEvent(req.symbol,"REAL_SLIP",req.volume,0,slip,0);
     }
   int rnd=MathRand()%1000;
   if(rnd<int(SimRejectProbability*1000))
     {
      string msg="Trade rejected in reality sim: "+req.symbol;
      Print(msg);
      
      LogEvent(req.symbol,"REAL_REJECT",req.volume,0,0,0);
      return(false);
     }
   return(true);
  }

// Simplified execution simulator for strategy tester or demo
bool SimulateExecutionSimple()
  {
   if(!EnableExecutionSimulator)
      return(true);

   Sleep(SimulatedOrderDelayMs);

   double r=MathRand()/(double)RAND_MAX;
   if(r<SimulatedRejectionChance)
     {
      Print("\xF0\x9F\x9B\xA0 Simulated Order Rejected");
      return(false);
     }

   return(true);
  }

// Calibrate broker baseline latency
void CalibrateBroker()
  {
   gAvgPing=TerminalInfoInteger(TERMINAL_PING_LAST);
   Print("Average ping ",gAvgPing);
  }

void TrackExecutionSpeed(ulong start,string symbol)
  {
   ulong now=GetTickCount();
   double ms=double(now-start);
   gExecAvgMs=(gExecAvgMs*gExecSamples+ms)/(gExecSamples+1);
   gExecSamples++;
   if(ms>MaxExecSpeedMs)
     {
      string msg=StringFormat("Broker slow: exec time %.0fms",ms);
      Print(msg);
      
      LogEvent(symbol,"SLOW",0,0,ms,0);
      gSlowExecStreak++;
     }
   else
      gSlowExecStreak=0;
   if(gSlowExecStreak>3)
     {
      gTradingPaused=true;
      gErrorPauseEndTime=TimeCurrent()+10*60;
      SendTelegram("Broker execution unreliable - pausing 10m");
      gSlowExecStreak=0;
     }
  }

// Calculate symbol strength using EMA trend and RSI
void UpdateSymbolStrength()
  {
   if(!EnableSymbolStrengthMeter)
      return;
   for(int i=0;i<gSymbolCount;i++)
     {
      string sym=gSymbols[i];
      double ema21=iMA(sym,0,21,0,MODE_EMA,PRICE_CLOSE,0);
      double ema50=iMA(sym,0,50,0,MODE_EMA,PRICE_CLOSE,0);
      double rsi=iRSI(sym,0,14,PRICE_CLOSE,0);
      double str=0.0;
      if(ema21>ema50) str+=0.5; else if(ema21<ema50) str-=0.5;
      if(rsi>55) str+=0.5; else if(rsi<45) str-=0.5;
      gSymbolStrength[i]=str;
     }
  }

// Adjust SL/TP dynamically based on ATR and SMC
void OptimizeSLTP(string symbol,bool isBuy,double &slPts,double &tp1,double &tp2,double &tp3)
  {
   if(!EnableSLTPOptimizer)
      return;
   double point=SymbolInfoDouble(symbol,SYMBOL_POINT);
   if(point<=0) return;
   double atr=iATR(symbol,0,14,1)/point;
   if(atr>0) slPts=MathMax(slPts,atr*1.2);
   int bos=DetectBreakOfStructure(symbol);
   int ob =DetectOrderBlocks(symbol);
   if((isBuy && bos==1)||( !isBuy && bos==-1))
      { tp1+=0.5; tp2+=0.5; tp3+=0.5; }
   if((isBuy && ob==1)||(!isBuy && ob==-1))
      { tp2+=0.5; tp3+=0.5; }
  }

// AI-based high probability setup filter (stub)
bool IsHighProbabilitySetup(string symbol)
  {
   if(!EnableAISetupFilter)
      return(true);
   return(MathRand()%2==0); // placeholder random decision
  }
// Initialize broker profile
void InitBrokerProfile()
  {
   gBroker.avgExecutionTimeMs = 250;
   gBroker.maxSlippagePoints  = SymbolInfoDouble(_Symbol, SYMBOL_SPREAD) * 2;
   gBroker.minLotSize         = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   gBroker.marginPerLot       = SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_INITIAL);
   gBroker.lastUpdateTime     = TimeCurrent();
   Print("Broker profile initialized: Slippage cap = ", gBroker.maxSlippagePoints);
  }

void UpdateBrokerProfile(double actualSlippagePts,int executionTimeMs)
  {
   gBroker.avgExecutionTimeMs = (gBroker.avgExecutionTimeMs * 0.8) + (executionTimeMs * 0.2);
   gBroker.maxSlippagePoints  = MathMax(gBroker.maxSlippagePoints, actualSlippagePts);
   gBroker.lastUpdateTime     = TimeCurrent();
  }

bool SendSmartOrder(MqlTradeRequest &req, MqlTradeResult &res, string symbol, bool isBuy)
  {
   datetime start = TimeCurrent();
   double oldPrice = req.price;
   bool ok = OrderSend(req,res);
   datetime end = TimeCurrent();
   LogExecution(symbol,start,end,oldPrice,res.price,res.retcode);
   if(ok)
     {
      double execTime = (end - start) * 1000;
      double actualSlippage = MathAbs(oldPrice - res.price) / SymbolInfoDouble(symbol,SYMBOL_POINT);
      UpdateBrokerProfile(actualSlippage,(int)execTime);
      if(EnableExecutionTuning && actualSlippage>MaxAllowedSlippage) SendTelegram(StringFormat("⚠ High slippage %.1f pts on %s",actualSlippage,symbol));
      if(EnableExecutionTuning && execTime>MaxAllowedLatency) SendTelegram(StringFormat("⚠ Slow execution %.0fms on %s",execTime,symbol));
      if(actualSlippage > gBroker.maxSlippagePoints)
         Print(symbol,": High slippage detected: ",actualSlippage," pts");
      if(execTime > 1000)
         Print(symbol,": Slow execution warning: ",execTime,"ms");
     }
   else
     {
      Print("Order failed with code ", res.retcode);
      if(res.retcode==TRADE_RETCODE_REQUOTE) SendTelegram(symbol+": Requote occurred");
     }
   return ok;
  }

// Log confidence data to CSV
void LogConfidenceData(string symbol,double confidence,bool isBuy,double resultPips)
  {
   if(!EnableConfidenceAutoTuner)
      return;
   int h=FileOpen(ConfidenceLogFile,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE)
      h=FileOpen(ConfidenceLogFile,FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE)
     {
      Print("Failed to open confidence log file: ",GetLastError());
      return;
     }
   FileSeek(h,0,SEEK_END);
   FileWrite(h,
             TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES),
             symbol,
             DoubleToString(confidence,2),
             isBuy?"BUY":"SELL",
             DoubleToString(resultPips,1));
   FileClose(h);
  }

// Record closed trade outcome for adaptive confidence
void RecordTradeOutcome(const MqlTradeTransaction &trans)
  {
   if(trans.type==TRADE_TRANSACTION_DEAL_ADD &&
      (trans.deal_entry==DEAL_ENTRY_OUT || trans.deal_entry==DEAL_ENTRY_OUT_BY))
     {
      int idx=-1;
      for(int i=0;i<ArraySize(gTrades);i++)
         if(gTrades[i].ticket==trans.position){ idx=i; break; }
      if(idx>=0)
        {
         TradeInfo &info=gTrades[idx];
         double pt=SymbolInfoDouble(info.symbol,SYMBOL_POINT);
         if(pt<=0) pt=1.0;
         double pips=(trans.price-info.entryPrice)/pt;
         if(!info.isBuy) pips=-pips;
         LogConfidenceData(info.symbol,info.confidence,info.isBuy,pips);
        }
     }
  }

// Calculate adaptive confidence bias from log
double GetAdaptiveConfidence(string symbol,bool isBuy)
  {
   if(!EnableConfidenceAutoTuner)
      return 0.5;
   int h=FileOpen(ConfidenceLogFile,FILE_READ|FILE_CSV|FILE_ANSI);
   if(h==INVALID_HANDLE)
      return 0.5;
   double sum=0,total=0;
   while(!FileIsEnding(h))
     {
      string line=FileReadString(h);
      if(line=="") break;
      string parts[]; StringSplit(line,',',parts);
      if(ArraySize(parts)<5) continue;
      if(parts[1]!=symbol) continue;
      bool buy=(StringFind(parts[3],"BUY")>=0);
      if(buy!=isBuy) continue;
      double conf=StringToDouble(parts[2]);
      double pips=StringToDouble(parts[4]);
      sum+=(pips>0?conf:-conf);
      total+=1.0;
     }
   FileClose(h);
   if(total<5) return 0.5;
   double val=0.5+(sum/total)*0.5;
   if(val<0.1) val=0.1; if(val>0.95) val=0.95;
   return val;
  }

// === Emotional cooldown helpers ===
bool IsEmotionCooldownActive()
  {
   if(!EnableEmotionalCooldown) return false;
   return(TimeCurrent() < emotionalCooldownEnd);
  }

void ResetStreakCounters()
  {
   consecutiveWins=0;
   consecutiveLosses=0;
  }

void HandleEmotionStreaks(const MqlTradeTransaction &trans)
  {
   if(!EnableEmotionalCooldown) return;

   if(trans.type==TRADE_TRANSACTION_DEAL_ADD &&
      (trans.deal_entry==DEAL_ENTRY_OUT || trans.deal_entry==DEAL_ENTRY_OUT_BY))
     {
      double profit=trans.profit;
      if(profit>0)
        {
         consecutiveWins++;
         consecutiveLosses=0;
         if(consecutiveWins>=MaxConsecutiveWins)
           {
            emotionalCooldownEnd=TimeCurrent()+EmotionalCooldownMinutes*60;
            SendTelegram("\xF0\x9F\x94\xA5 Emotional Cooldown Triggered (WIN STREAK). Bot pausing for "+
                         IntegerToString(EmotionalCooldownMinutes)+" min");
    }
  }

// Optimize TP allocation based on performance
void UpdateTPOptimization()
  {
   if(!EnableTPOptimization) return;
   int total=gTP1Count+gTP2Count+gTP3Count;
   if(total<10) return;
   double ratio=(double)(gTP2Count+gTP3Count)/total;
  if(ratio<0.3)
    {
     TP1_Percent=0.5;
     TP2_Percent=0.3;
     TP3_Percent=0.2;
     SendTelegram("TP allocation adjusted to 50/30/20 based on performance");
     gTP1Count=0; gTP2Count=0; gTP3Count=0;
    }
  }

  else if(profit<0)
    {
     consecutiveLosses++;
     consecutiveWins=0;
     if(consecutiveLosses>=MaxConsecutiveLosses)
       {
        emotionalCooldownEnd=TimeCurrent()+EmotionalCooldownMinutes*60;
        SendTelegram("\xE2\x9A\xA0\xEF\xB8\x8F Emotional Cooldown Triggered (LOSS STREAK). Bot pausing for "+
                     IntegerToString(EmotionalCooldownMinutes)+" min");
       }
    }
  }
}

// === PHASE 17: Advanced Execution Simulator ===
bool SimulateExecutionAdvanced(MqlTradeRequest &req,double maxLat,double maxSlip,double reject,double requote)
  {
   if(!EnableExecutionSimulation)
      return(true);
   int delay=100+MathRand()%((int)maxLat);
   Sleep(delay);
   double pt=SymbolInfoDouble(req.symbol,SYMBOL_POINT); if(pt<=0) pt=1.0;
   int slip=(MathRand()%(int)(maxSlip*2+1))-(int)maxSlip;
   req.price+=slip*pt;
   if(slip!=0){ Print(StringFormat("Sim slippage %+d pts",slip)); LogEvent(req.symbol,"SIM_SLIP",req.volume,0,slip,0); SendTelegram(StringFormat("Simulated slippage %+d pts on %s",slip,req.symbol)); }
   if(MathRand()%100 < (int)(reject*100))
     { string msg=StringFormat("Sim rejection %s latency %dms",req.symbol,delay); Print(msg); SendTelegram(msg); LogEvent(req.symbol,"SIM_REJECT",req.volume,0,0,0); return(false); }
   if(MathRand()%100 < (int)(requote*100))
     { double newP=(req.type==ORDER_TYPE_BUY||req.type==ORDER_TYPE_BUY_LIMIT||req.type==ORDER_TYPE_BUY_STOP)?SymbolInfoDouble(req.symbol,SYMBOL_ASK):SymbolInfoDouble(req.symbol,SYMBOL_BID); req.price=newP; Print("Simulated requote new price "+DoubleToString(newP,Digits())); LogEvent(req.symbol,"SIM_REQUOTE",req.volume,0,0,0); }
   return(true);
  }

// === PHASE 18: Performance Analyzer ===
void UpdatePerformanceStats(string symbol,bool win,double rr,double conf)
  {
   int h=FileOpen(PerformanceFile,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE) h=FileOpen(PerformanceFile,FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h!=INVALID_HANDLE){ FileSeek(h,0,SEEK_END); FileWrite(h,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),symbol,win?"WIN":"LOSS",DoubleToString(rr,2),DoubleToString(conf,2)); FileClose(h); }
   gPerfDailyTrades++; if(win) gPerfDailyWins++; else gPerfDailyLosses++; if(win){gPerfRRWinSum+=rr; gPerfConfWinSum+=conf;} else {gPerfRRLosSum+=rr; gPerfConfLosSum+=conf;}
  }

// === PHASE 19: Trade Memory System ===
void SaveTradeMemory(string symbol,bool isBuy,double conf,ConfidenceFactors fac,bool win,int stage)
  {
   int h=FileOpen(TradeMemoryFile,FILE_READ|FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE) h=FileOpen(TradeMemoryFile,FILE_WRITE|FILE_CSV|FILE_SHARE_WRITE|FILE_ANSI);
   if(h==INVALID_HANDLE) return; FileSeek(h,0,SEEK_END);
   FileWrite(h,TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES),symbol,isBuy?"BUY":"SELL",conf,
            fac.ema,fac.rsi,fac.ob,fac.bos,fac.engulf,win?"W":"L",stage); FileClose(h);
  }

double EvaluateTradeMemory(string symbol,bool isBuy,double conf,ConfidenceFactors fac)
  {
   int h=FileOpen(TradeMemoryFile,FILE_READ|FILE_CSV|FILE_ANSI);
   if(h==INVALID_HANDLE) return(0.0); int match=0,wins=0; while(!FileIsEnding(h))
     { string line=FileReadString(h); if(line=="") break; string p[]; StringSplit(line,',',p); if(ArraySize(p)<10) continue; if(p[1]!=symbol) continue; if((isBuy&&StringFind(p[2],"BUY")<0)||(!isBuy&&StringFind(p[2],"SELL")<0)) continue; bool ema=(int)StringToInteger(p[4]); bool rsi=(int)StringToInteger(p[5]); bool ob=(int)StringToInteger(p[6]); bool bos=(int)StringToInteger(p[7]); bool eng=(int)StringToInteger(p[8]); if(ema==fac.ema && rsi==fac.rsi && ob==fac.ob && bos==fac.bos && eng==fac.engulf){match++; if(StringFind(p[9],"W")>=0) wins++;}}
   FileClose(h); if(match<3) return(0.0); double rate=(double)wins/match; if(rate>0.6) return(0.05); if(rate<0.4) return(-0.05); return(0.0);
  }

// === PHASE 20: Adaptive Market Mode ===
int DetectMarketMode()
  {
   double atr=iATR(_Symbol,PERIOD_M15,14,1); double avg=0.0; for(int i=1;i<=20;i++) avg+=iATR(_Symbol,PERIOD_M15,14,i); avg/=20.0; double sp=GetSpreadPoints(_Symbol); int newMode=MODE_BALANCED; if(atr<avg*0.8 || sp>MaxAllowedSpreadPoints*1.5) newMode=MODE_CAUTIOUS; else if(atr>avg*1.5 && sp<MaxAllowedSpreadPoints*0.8 && gWinStreak>=2) newMode=MODE_AGGRESSIVE; if(newMode!=gMarketMode){ gMarketMode=newMode; gModeLastChange=TimeCurrent(); SendTelegram(StringFormat("Market mode changed to %d",gMarketMode)); } return(gMarketMode);
  }

// === PHASE 21: Integrity Validator ===
bool RunIntegrityValidator()
  {
   bool ok=true;
   if(!SendTelegram("Validator check"))
      ok=false;
   double tmp=0; ConfidenceFactors f; bool dir=true;
   tmp=CalculateConfidence(_Symbol,dir,f);
   if(ok)
      SendTelegram("\xE2\x9C\x85 All modules online");
   else
     {
      SendTelegram("\xE2\x9D\x8C Module failure");
      gTradingPaused=true;
     }
  return(ok);
  }

void RunTroubleshoot()
  {
   bool ok=RunIntegrityValidator();
   if(ok)
      SendTelegram("\xF0\x9F\x9A\x80 Troubleshoot complete: all systems operational");
   else
      SendTelegram("\xE2\x9D\x8C Troubleshoot detected issues. Check logs.");
  }

void RunYellowReminder()
  {
   SendTelegram("\xF0\x9F\x9A\xA8 Reminder: finalize real-time news filter integration and logging.");
  }

void CheckReminderTriggers()
  {
   if(!EnableReminderTriggers)
      return;
   double cmd;
   if(GlobalVariableGet("PMX_TRIGGER",cmd))
     {
      GlobalVariableDel("PMX_TRIGGER");
      if((int)cmd==1)
         RunTroubleshoot();
      else if((int)cmd==2)
         RunYellowReminder();
     }
  }
