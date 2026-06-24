//+------------------------------------------------------------------+
//| USTEC_ExportRatesToJson.mq5                                      |
//| Educational candle exporter Script using CopyRates only.          |
//|                                                                  |
//| This is not an Expert Advisor and never opens, modifies, or       |
//| closes trades. It exports local candle data selected by the user. |
//+------------------------------------------------------------------+
#property strict
#property script_show_inputs

input string   InpSymbol       = "USTEC";
input datetime InpStartDate    = D'2025.01.01 00:00';
input datetime InpEndDate      = D'2026.06.05 23:59';
input bool     InpExportM1     = true;
input bool     InpExportM5     = true;
input bool     InpExportM15    = true;
input bool     InpExportH1     = true;
input bool     InpExportD1     = true;
input string   InpOutputPrefix = "exports\\rates";

string TimeframeName(const ENUM_TIMEFRAMES timeframe)
{
   if(timeframe == PERIOD_M1)  return "M1";
   if(timeframe == PERIOD_M5)  return "M5";
   if(timeframe == PERIOD_M15) return "M15";
   if(timeframe == PERIOD_H1)  return "H1";
   if(timeframe == PERIOD_D1)  return "D1";
   return "UNKNOWN";
}

string SafeSymbolName(const string symbol_name)
{
   string output = symbol_name;
   StringReplace(output, "\\", "_");
   StringReplace(output, "/", "_");
   StringReplace(output, ":", "_");
   StringReplace(output, " ", "_");
   return output;
}

string IsoTime(const datetime value)
{
   return TimeToString(value, TIME_DATE | TIME_MINUTES | TIME_SECONDS);
}

bool ExportTimeframe(const string symbol_name,
                     const ENUM_TIMEFRAMES timeframe,
                     const datetime start_date,
                     const datetime end_date,
                     const string output_prefix,
                     int &rows_exported,
                     string &file_name)
{
   rows_exported = 0;
   const string tf_name = TimeframeName(timeframe);
   MqlRates rates[];
   ArraySetAsSeries(rates, false);

   const int copied = CopyRates(symbol_name, timeframe, start_date, end_date, rates);
   if(copied <= 0)
   {
      PrintFormat("CopyRates failed for %s %s. copied=%d error=%d",
                  symbol_name, tf_name, copied, GetLastError());
      return false;
   }

   FolderCreate(output_prefix);
   file_name = output_prefix + "\\" + SafeSymbolName(symbol_name) + "_" + tf_name + ".jsonl";
   const int handle = FileOpen(file_name, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(handle == INVALID_HANDLE)
   {
      PrintFormat("FileOpen failed for %s. error=%d", file_name, GetLastError());
      return false;
   }

   for(int i = 0; i < copied; i++)
   {
      const string line = StringFormat(
         "{\"time\":\"%s\",\"open\":%.8f,\"high\":%.8f,\"low\":%.8f,\"close\":%.8f,\"volume\":%I64d,\"tick_volume\":%I64d,\"spread\":%d,\"real_volume\":%I64d,\"symbol\":\"%s\",\"timeframe\":\"%s\"}",
         IsoTime(rates[i].time),
         rates[i].open,
         rates[i].high,
         rates[i].low,
         rates[i].close,
         rates[i].tick_volume,
         rates[i].tick_volume,
         rates[i].spread,
         rates[i].real_volume,
         symbol_name,
         tf_name
      );
      FileWriteString(handle, line + "\n");
      rows_exported++;
   }

   FileClose(handle);
   PrintFormat("Exported %d rows to %s", rows_exported, file_name);
   return true;
}

void WriteManifest(const string output_prefix,
                   const string symbol_name,
                   const datetime start_date,
                   const datetime end_date,
                   const int total_rows,
                   const int successful_files,
                   const int failed_files)
{
   FolderCreate(output_prefix);
   const string manifest_name = output_prefix + "\\" + SafeSymbolName(symbol_name) + "_manifest.json";
   const int handle = FileOpen(manifest_name, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(handle == INVALID_HANDLE)
   {
      PrintFormat("Manifest FileOpen failed for %s. error=%d", manifest_name, GetLastError());
      return;
   }

   const string manifest = StringFormat(
      "{\"symbol\":\"%s\",\"start\":\"%s\",\"end\":\"%s\",\"total_rows\":%d,\"successful_files\":%d,\"failed_files\":%d,\"exporter\":\"USTEC_ExportRatesToJson.mq5\",\"trade_data_exported\":false,\"account_data_exported\":false}",
      symbol_name,
      IsoTime(start_date),
      IsoTime(end_date),
      total_rows,
      successful_files,
      failed_files
   );
   FileWriteString(handle, manifest + "\n");
   FileClose(handle);
   PrintFormat("Manifest written to %s", manifest_name);
}

void OnStart()
{
   if(InpSymbol == "")
   {
      Print("InpSymbol is empty. Export stopped.");
      return;
   }

   if(InpEndDate <= InpStartDate)
   {
      Print("InpEndDate must be greater than InpStartDate. Export stopped.");
      return;
   }

   SymbolSelect(InpSymbol, true);

   ENUM_TIMEFRAMES timeframes[5] = { PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_H1, PERIOD_D1 };
   bool enabled[5] = { InpExportM1, InpExportM5, InpExportM15, InpExportH1, InpExportD1 };

   int total_rows = 0;
   int successful_files = 0;
   int failed_files = 0;

   for(int i = 0; i < 5; i++)
   {
      if(!enabled[i])
         continue;

      int rows = 0;
      string file_name = "";
      if(ExportTimeframe(InpSymbol, timeframes[i], InpStartDate, InpEndDate, InpOutputPrefix, rows, file_name))
      {
         total_rows += rows;
         successful_files++;
      }
      else
      {
         failed_files++;
      }
   }

   WriteManifest(InpOutputPrefix, InpSymbol, InpStartDate, InpEndDate, total_rows, successful_files, failed_files);
   PrintFormat("USTEC export finished. total_rows=%d successful_files=%d failed_files=%d",
               total_rows, successful_files, failed_files);
}
