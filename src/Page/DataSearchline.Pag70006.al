page 70006 "DS Data Search line"
{
    ApplicationArea = All;
    Caption = 'DS Data Search line';
    PageType = Card;
    SourceTable = "DS Data Search Result";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field(Description; Rec.Description)
                {
                }
                field("Entry No."; Rec."Entry No.")
                {
                }
                field("Line Type"; Rec."Line Type")
                {
                }
                field("No. of Hits"; Rec."No. of Hits")
                {
                }
                field("Parent ID"; Rec."Parent ID")
                {
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                }
                field(SystemId; Rec.SystemId)
                {
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                }
                field("Table No."; Rec."Table No.")
                {
                }
                field("Table Subtype"; Rec."Table Subtype")
                {
                }
                field("Table Caption"; Rec."Table Caption")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        ShowRecord();
        Error('');
    end;


    internal procedure ShowRecord()
    var
        DataSearchResultRecords: page "DS Data Search Result Records";
        RecRef: RecordRef;
        PageNo: Integer;
        DataSearchEvents: Codeunit "DS Data Search Events";
        DataSearchSetupTable: Record "DS Data Search Setup (Table)";
    begin
        case Rec."Line Type" of
            Rec."Line Type"::Header:
                begin
                    PageNo := Rec.GetListPageNo();
                    DataSearchEvents.OnAfterGetListPageNo(Rec, PageNo, DataSearchSetupTable.GetRoleCenterID(), Rec.SearchString);
                    if PageNo > 0 then
                        Page.Run(PageNo);
                end;
            Rec."Line Type"::MoreHeader:
                begin
                    RecRef.Open(Rec."Table No.");
                    DataSearchResultRecords.SetSourceRecRef(RecRef, Rec."Table Subtype", Rec.SearchString, Rec.GetTableCaption()); //TODO
                    DataSearchResultRecords.Run();
                end;
            Rec."Line Type"::Data:
                begin
                    RecRef.Open(Rec."Table No.");
                    if not RecRef.GetBySystemId(Rec."Parent ID") then
                        exit;
                    ShowPagePhone(RecRef, Rec."Table Subtype");
                end;
        end;
    end;

    internal procedure ShowPagePhone(var RecRef: RecordRef)
    begin
        ShowPagePhone(RecRef, Rec."Table Subtype");
    end;

    internal procedure ShowPagePhone(var RecRef: RecordRef; TableType: Integer)
    var
        TableMetadata: Record "Table Metadata";
        PageMetaData: Record "Page Metadata";
        PageManagement: Codeunit "Page Management";
        DataSearchEvents: Codeunit "DS Data Search Events";
        RecVariant: Variant;
        PageNo: Integer;
    begin
        Rec.MapLinesRecToHeaderRec(RecRef);
        RecVariant := RecRef;
        if not PageManagement.PageRun(RecVariant) then begin
            DataSearchEvents.OnGetCardPageNo(RecRef.Number, TableType, PageNo);
            if PageNo = 0 then begin
                if not TableMetadata.Get(RecRef.Number) then
                    exit;
                PageNo := TableMetadata.LookupPageID;
                if not PageMetaData.Get(PageNo) then
                    exit;
                if PageMetaData.CardPageID <> 0 then
                    PageNo := PageMetaData.CardPageID;
            end;
            Page.Run(PageNo, RecVariant);
        end;
    end;
}