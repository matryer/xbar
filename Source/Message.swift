enum Message {
  case bashScriptFinished(Script.Result)
  case bashScriptOpened(String)
  case menuTriggeredRefresh
  case titleTriggeredRefresh
}
