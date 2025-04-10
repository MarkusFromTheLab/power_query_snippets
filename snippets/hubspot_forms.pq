    // This function retrieves data from the forms endpoint in HubSpot 
    // It supportsmulti-page results and refeshes in PowerBi Service / RS
    // without dynamic data sources errors. 
let
    // Replace with your HubSpot API key
    ApiKey = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
 
    // Replace with the Form ID you want to retrieve submissions for
    FormGuid = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",

    RelativePath = "/form-integrations/v1/submissions/forms/",
    GetSubmissions = (formGuid as text, optional offset as text) =>
        let
            QueryOptions = if offset = null then [] else [after = offset],
            FullUrl = RelativePath & formGuid,
            Source = Json.Document(Web.Contents("https://api.hubapi.com", [
                RelativePath = FullUrl,
                Query = QueryOptions,
                Headers = [#"Authorization" = "Bearer " & ApiKey]
            ])),
            Results = Source[results],
            Paging = try Source[paging] otherwise null,
            NextOffset = if Paging <> null then Paging[next][after] else null,
            CombinedResults = if NextOffset = null then Results else Results & @GetSubmissions(formGuid, NextOffset)
        in
            CombinedResults,
    Submissions = GetSubmissions(FormGuid),
    ConvertedToTable = Table.FromList(Submissions, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
in
      ConvertedToTable
