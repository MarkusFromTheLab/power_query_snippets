    // This function retrieves data of all members of a list from the 
    // lists endpoint in HubSpot. It supportsmulti-page results and 
    // refeshes in PowerBi Service / RS without dynamic data sources errors. 
let
    // Replace with your HubSpot API key
    ApiKey = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
 
    // Replace with the list ID
    RecordId = "XXXXXX",
 
    RelativePath = "/crm/v3/lists/",
    GetMemberships = (recordId as text, optional after as text) =>
        let
            QueryOptions = if after = null then [] else [after = after],
            FullUrl = RelativePath & recordId & "/memberships",
            Source = Json.Document(Web.Contents("https://api.hubapi.com", [
                RelativePath = FullUrl,
                Query = QueryOptions,
                Headers = [#"Authorization" = "Bearer " & ApiKey]
            ])),
            Results = Source[results],
            Paging = try Source[paging] otherwise null,
            NextAfter = if Paging <> null and Record.HasFields(Paging,{"next"}) then Paging[next][after] else null,
            CombinedResults = if NextAfter = null then Results else Results & @GetMemberships(recordId, NextAfter)
        in
            CombinedResults,
    Memberships = GetMemberships(RecordId),
    ConvertedToTable = Table.FromList(Memberships, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
in
      ConvertedToTable
