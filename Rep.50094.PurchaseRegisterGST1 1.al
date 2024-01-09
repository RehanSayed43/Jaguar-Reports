report 50094 "Purchase Register"
{
    UsageCategory = Administration;
    ApplicationArea = ALL;
    DefaultLayout = RDLC;
    RDLCLayout = './PurchaseRegisterGST1.rdl'; //PurchaseRegisterGST1.rdl

    dataset
    {
        //dataitem(DataItem1000000000; Table122)
        dataitem("Purch. Inv. Header"; "Purch. Inv. Header")
        {

            column(Srno; Srno)
            {
            }
            column(BC_Document_Type; "Purch. Inv. Line"."Source Document Type") { }
            column(Document_No; "No.") { }
            column(Vendor_Name; "Buy-from Vendor Name") { }
            column(Pay_to_Vendor_No_; "Pay-to Vendor No.") { }
            column(Gstno; "Vendor GST Reg. No.") { }
            column(Vedor_PostingGrp; PostingDes) { }
            column(Vendor_Invoice_No_; "Vendor Invoice No.") { }
            column(Posting_Date; "Posting Date")
            {
                // Caption = 'Invoice Date';
            }
            column(Procurement_Type; "Nature of Supply") { }
            column(Location_State_Code; "Location State Code" + '' + '-' + '(' + "recStateDesc" + ')') { }
            column(Place_Of_Supply; "Ship-to City") { }

            // column(salespnm; purchaserCode)
            // {
            // }
            column(startdt; startdt)
            {
            }
            column(enddt; enddt)
            {
            }

            column(MapleGSTIN; MapleGSTIN)
            {
            }
            //dataitem(DataItem1000000001; Table123)
            dataitem("Purch. Inv. Line"; "Purch. Inv. Line")
            {
                DataItemLinkReference = "Purch. Inv. Header";
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = where("No." = filter(<> ''));
                //kj_filter  //DataItemTableView = WHERE(Type = FILTER("G/L Account" | Item | "Charge (Item)" | "Fixed Asset"), Quantity = FILTER(<> 0));
                //  DataItemTableView = where(Quantity = FILTER(<> 0), Type = filter(Item | "G/L Account" | "Charge (Item)" | "Fixed Asset"));
                column(Client_G_L_Account_No_; "Client G/L Account No.") { }
                column(Description; Description) { }
                column(HSN_SAC_Code; "HSN/SAC Code") { }
                column(Classification; name) { }
                column(Eligibility; "GST Credit") { }
                column(GSTCode; "GST Group Code") { }
                column(RCM; GST12) { }
                column(Taxable_Value; "Line Amount") { } //taxable
                column(Rate_of_Tax; totalRate) { }
                column(Integrated_tax; IGSTAmt) { }
                column(Central_Tax; CGSTAmt) { }
                column(State_Tax; SGSTAmt) { }
                column(Total_Invoice; Final_Amount) { }



                trigger OnAfterGetRecord()
                begin
                    // clear(total);
                    // clear(Total_Amount);
                    // clear(Final_Amount);

                    // "Purch. Inv. Line".Reset();
                    // "Purch. Inv. Line".SetRange("Document No.", "Purch. Inv. Header"."No.");
                    // if "Purch. Inv. Line".FindSet() then begin
                    //     repeat
                    //         total += "Purch. Inv. Line"."Line Amount";
                    //     until "Purch. Inv. Line".Next() = 0;

                    // end;
                    CLEAR(CGSTRate);

                    CLEAR(CGSTAmt);

                    CLEAR(GSTComponentCGST);

                    CLEAR(SGSTRate);

                    CLEAR(SGSTAmt);

                    CLEAR(GSTComponentSGST);

                    CLEAR(IGSTRate);

                    CLEAR(IGSTAmt);

                    CLEAR(GSTComponentIGST);
                    GSTDetailLeger.Reset();
                    GSTDetailLeger.SetRange("Document No.", "Purch. Inv. Line"."Document No.");
                    GSTDetailLeger.SetRange("No.", "Purch. Inv. Line"."No.");
                    GSTDetailLeger.SetRange("Document Line No.", "Purch. Inv. Line"."Line No.");
                    If GSTDetailLeger.FindSet() then
                        repeat
                            if GSTDetailLeger."GST Component Code" = 'CGST' then begin
                                GSTComponentCGST := 'CGST';
                                CGSTAmt := abs(GSTDetailLeger."GST Amount");
                                CGSTRate := GSTDetailLeger."GST %";

                            end else
                                if GSTDetailLeger."GST Component Code" = 'SGST' then begin
                                    GSTComponentSGST := 'SGST';
                                    SGSTAmt := abs(GSTDetailLeger."GST Amount");
                                    SGSTRate := GSTDetailLeger."GST %";

                                end else
                                    if GSTDetailLeger."GST Component Code" = 'IGST' then begin
                                        GSTComponentIGST := 'IGST';
                                        IGSTAmt := Abs(GSTDetailLeger."GST Amount");
                                        IGSTRate := Abs(GSTDetailLeger."GST %");

                                    end;

                        until GSTDetailLeger.next = 0;
                    totalRate := CGSTRATE + SGSTRATE + IGSTRATE;
                    Total_Amount := "Line Amount" + CGSTAmt + SGSTAmt + IGSTAmt;
                    Final_Amount := Total_Amount;

                    if GSTComponentCGST = 'SGST' then begin
                        GstCredit := 'Yes';


                    end else
                        if GSTComponentCGST = 'CGST' then begin
                            GstCredit := 'Yes'
                        end else
                            if GSTComponentCGST = 'IGST' then begin
                                GstCredit := 'Yes'
                            end else begin
                                GstCredit := 'No'
                            end;


                    clear(GST12);
                    GstGroup.Reset();
                    GstGroup.setrange(Code, "Purch. Inv. Line"."GST Group Code");
                    if GstGroup."Reverse Charge" = false then begin
                        GST12 := 'No'
                    end else begin
                        GST12 := 'Yes'

                    end;

                    GLacc.Reset();
                    GLacc.SetRange("No.", "Purch. Inv. Line"."No.");
                    GLacc.SetFilter("No.", '1000810');
                    if GLacc.FindFirst() then// begin
                                             //name := 'Capital Work-in-Progress'
                        name := 'INPUT Service'
                    else
                        name := 'CG';
                    EmieNo := '';
                    SrlNo := '';


                    // "Purch. Inv. Line".Reset();
                    // "Purch. Inv. Line".SetRange("No.", "Purch. Inv. Line"."Document No.");
                    // "Purch. Inv. Line".SetFilter("GST Credit", 'Availment');
                    // if "Purch. Inv. Line". then begin
                    //     GstCredit := 'Yes'
                    //     else
                    //     GstCredit := 'No';

                    // end;
                    // Purchinvline.Reset();

                    // Clear(GstCredit);

                    // if Purchinvline."GST Credit" = Purchinvline."GST Credit"::Availment then begin
                    //     GstCredit := 'Yes'
                    // end
                    // else
                    //     GstCredit := 'No';







                    ServTaxPerc := 0;

                end;

                trigger OnPreDataItem()
                begin
                    ServTaxPerc := 0;
                    PRDt := 0D;
                    Purchinvline.Reset();

                    Clear(GstCredit);


                    // if "Purch. Inv. Line"."GST Credit" = "Purch. Inv. Line"."GST Credit"::Availment then
                    //     GstCredit := 'Yes';

                    // if "Purch. Inv. Line"."GST Credit" = "Purch. Inv. Line"."GST Credit"::" " then
                    //     GstCredit := 'NO';
                    // if "Purch. Inv. Line"."GST Credit" = "Purch. Inv. Line"."GST Credit"::"Non-Availment" then
                    //     GstCredit := 'NO';

                end;
            }

            trigger OnAfterGetRecord()
            begin

                PostingG.Reset();
                PostingG.SetRange(Code, "Purch. Inv. Header"."Vendor Posting Group");
                if PostingG.FindFirst() then begin
                    PostingDes := PostingG.Description;
                end;

                recstate.Reset();
                recstate.SetRange(Code, "Purch. Inv. Header"."Location State Code");
                if recstate.FindFirst() then begin
                    recstateDesc := recstate.Description;
                end;

                Srno += 1;





            end;

            trigger OnPreDataItem()
            begin
                Srno := 0;

                "Purch. Inv. Header".SETRANGE("Purch. Inv. Header"."Posting Date", startdt, enddt);
                //IF "Purch. Inv. Header".FINDSET THEN;
                // "Purch. Inv. Header"."Purchaser Code" := '';
            end;
        }
        //dataitem(DataItem1000000070; Table124)
        dataitem("Purch. Cr. Memo Hdr."; "Purch. Cr. Memo Hdr.")
        {
            column(SrnoCRR; SrnoCM)
            {
            }
            column(BC_Document_TypeCRR; "Purch. Inv. Line"."Source Document Type") { }
            column(Document_NoCRR; "No.") { }
            column(Vendor_NameCRR; "Buy-from Vendor Name") { }
            column(Pay_to_Vendor_No_s; "Pay-to Vendor No.") { }
            column(GstnoCRR; "Vendor GST Reg. No.") { }
            column(Vedor_PostingGrpCRR; PostingDes) { }
            column(Vendor_Cr__Memo_No_; "Vendor Cr. Memo No.") { }
            column(Posting_DateCR; "Posting Date")
            {
                // Caption = 'Invoice Date';
            }
            column(Procurement_TypeCRR; "Nature of Supply") { }
            column(Location_State_CodeCRR; "Location State Code" + '' + '-' + '(' + "recStateDesc" + ')') { }
            column(Place_Of_SupplyCRR; "Ship-to City") { }
            column(text1; text1) { }

            // column(salespnm; purchaserCode)
            // {
            // }
            // column(startdt; startdt)
            // {
            // }
            // column(enddt; enddt)
            // {
            // }


            //dataitem(DataItem1000000071; Table125)
            dataitem("Purch. Cr. Memo Line"; "Purch. Cr. Memo Line")
            {
                DataItemLinkReference = "Purch. Cr. Memo Hdr.";
                DataItemLink = "Document No." = FIELD("No.");
                // DataItemTableView = WHERE(Type = FILTER("G/L Account" | Item | 'Charge (Item)' | "Fixed Asset"),
                //  Quantity = FILTER(<> 0)); //kj
                //  DataItemTableView = where(Quantity = FILTER(<> 0), Type = filter(Item | "G/L Account" | "Charge (Item)" | "Fixed Asset")); //kj
                DataItemTableView = where("No." = filter(<> ''));
                column(No_; "No.") { }
                column(Client_G_L_Account_No_CRR; "Client G/L Account No.") { }
                column(DescriptionCRR; Description) { }
                column(HSN_SAC_CodeCRR; "HSN/SAC Code") { }
                column(ClassificationCRR; namecr) { } ///Do this
                column(EligibilityCRR; "GST Credit") { }//Do this
                column(GSTCodeCRR; "GST Group Code") { }
                column(RCMCRR; GST12CR) { }    //Do this
                column(Taxable_ValueCRR; "Line Amount") { } //taxable
                column(Rate_of_TaxCRR; totalRate) { }
                column(Integrated_taxCRR; IGSTAmt) { }
                column(Central_TaxCRR; CGSTAmt) { }
                column(State_TaxCRR; SGSTAmt) { }
                column(Total_InvoiceCRR; Final_Amount) { }
                trigger OnAfterGetRecord()
                var

                begin
                    text1 := '-';


                    // clear(total);
                    // clear(Total_Amount);
                    // clear(Final_Amount);
                    // "Purch. Inv. Line".Reset();
                    // "Purch. Inv. Line".SetRange("Document No.", "Purch. Inv. Header"."No.");
                    // if "Purch. Inv. Line".FindSet() then begin
                    //     repeat
                    //         total += "Purch. Inv. Line"."Line Amount";
                    //     until "Purch. Inv. Line".Next() = 0;

                    // end;
                    CLEAR(CGSTRate);

                    CLEAR(CGSTAmt);

                    CLEAR(GSTComponentCGST);

                    CLEAR(SGSTRate);

                    CLEAR(SGSTAmt);

                    CLEAR(GSTComponentSGST);

                    CLEAR(IGSTRate);

                    CLEAR(IGSTAmt);

                    CLEAR(GSTComponentIGST);
                    GSTDetailLeger.Reset();
                    GSTDetailLeger.SetRange("Document No.", "Purch. Cr. Memo Line"."Document No.");
                    GSTDetailLeger.SetRange("No.", "Purch. Cr. Memo Line"."No.");
                    GSTDetailLeger.SetRange("Document Line No.", "Purch. Cr. Memo Line"."Line No.");
                    If GSTDetailLeger.FindSet() then
                        repeat
                            if GSTDetailLeger."GST Component Code" = 'CGST' then begin
                                GSTComponentCGST := 'CGST';
                                CGSTAmt := abs(GSTDetailLeger."GST Amount");
                                CGSTRate := GSTDetailLeger."GST %";
                            end else
                                if GSTDetailLeger."GST Component Code" = 'SGST' then begin
                                    GSTComponentSGST := 'SGST';
                                    SGSTAmt := abs(GSTDetailLeger."GST Amount");
                                    SGSTRate := GSTDetailLeger."GST %";
                                end else
                                    if GSTDetailLeger."GST Component Code" = 'IGST' then begin
                                        GSTComponentIGST := 'IGST';
                                        IGSTAmt := Abs(GSTDetailLeger."GST Amount");
                                        IGSTRate := Abs(GSTDetailLeger."GST %");
                                    end;

                        until GSTDetailLeger.next = 0;
                    totalRate := CGSTRATE + SGSTRATE + IGSTRATE;

                    Total_Amount := "Line Amount" + CGSTAmt + SGSTAmt + IGSTAmt;
                    Final_Amount := Total_Amount;

                    clear(GST12);
                    GstGroup.Reset();
                    GstGroup.setrange(Code, PurchCrMemoLine."GST Group Code");
                    if GstGroup."Reverse Charge" = false then begin
                        GST12CR := 'No'
                    end else begin
                        GST12CR := 'Yes'

                    end;

                    GLacc.Reset();
                    GLacc.SetRange("No.", "Purch. Cr. Memo Line"."No.");
                    GLacc.SetFilter("No.", '1000810');
                    if GLacc.FindFirst() then// begin
                                             //name := 'Capital Work-in-Progress'
                        namecr := 'INPUT Service'
                    else
                        namecr := 'CG';
                    // EmieNo := '';
                    SrlNo := '';


                    //  ServTaxPerc := 0;

                end;

            }

            trigger OnAfterGetRecord()
            begin

                //MJ
                // IF RecVendor2.GET("Buy-from Vendor No.") THEN;
                // IF RecState2.GET(RecVendor2."State Code") THEN;
                // PlaceofSupply_CR := RecState2.Description + '(' + RecState2."State Code (GST Reg. No.)" + ')';
                // IF recLoc1.GET("Purch. Cr. Memo Hdr."."Location Code") THEN;
                // IF recVen1.GET("Purch. Cr. Memo Hdr."."Pay-to Vendor No.") THEN;
                // IF payterms1.GET("Purch. Cr. Memo Hdr."."Payment Terms Code") THEN;
                //MJ
                SrnoCM += 1;
            end;

            trigger OnPreDataItem()
            begin
                SrnoCM := 0;
                "Purch. Cr. Memo Hdr.".SETRANGE("Purch. Cr. Memo Hdr."."Posting Date", startdt, enddt); //MJ
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    field("Start Date"; startdt)
                    {
                        ApplicationArea = All;
                    }
                    field("End Date"; enddt)
                    {
                        ApplicationArea = All;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        // IMEI_SERIAL_SHOW := FALSE
    end;

    // trigger OnPreReport()
    // begin
    //     //RecItemLed.GET;

    //     cnt := 1;
    //     IF USERID IN ['ADMIN', 'ACCAPV', 'PUREXE2'] THEN
    //         IMEI_SERIAL_SHOW := TRUE
    //     ELSE
    //         IMEI_SERIAL_SHOW := FALSE; //Win-234 20-03-2019
    // end;

    var
        salesp: Record "Salesperson/Purchaser";//"13";
        staterec: Record State;//"13762";
        item: Record Item;//"27";
                          // schem: Record "Scheme Details";//"50001";
        GstCredit: Code[20];
        saleshdr: Record "Sales Header";//"36";
        purchhdr: Record "Purchase Header";//"38";
        Srno: Integer;
        SrnoCM: Integer;
        startdt: Date;
        enddt: Date;
        namecr: text[100];
        RecVendor: Record Vendor;//"23";
        CompInfo: Record "Company Information";//"79";
        payterms: Record "Payment Terms";//"3";
        postedshipment: Record "Purch. Rcpt. Header";//"120";
        RecItemLed: Record "Item Ledger Entry";//"32";
        PurchLine: Record "Purchase Line";//"39";
        ServTaxPerc: Decimal;
        PurchRectLine: Record "Purch. Rcpt. Line";//"121";
        PRDt: Date;
        EmieNo: Code[30];
        SrlNo: Code[30];
        cnt: Integer;
        PINVL: Record "Purch. Inv. Line";//"123";
        ServTaxamt: Decimal;
        reclocation: Record Location;//"14";
        glacnt: Record "G/L Account";//"15";
        GRTOTLCY: Decimal;
        GST12CR: Text[10];
        purchaserCode: Code[50];
        VendorPartCode: Code[50];
        GSTDetailLeger: Record "Detailed GST Ledger Entry";//"16419";
        CGSTRates: Decimal;
        CGSTAmt: Decimal;
        SGSTAmt: Decimal;
        SGSTRates: Decimal;
        IGSTRates: Decimal;
        IGSTAmt: Decimal;
        GSTComponentCGST: Text;
        GSTComponentSGST: Text;
        GSTComponentIGST: Text;
        GSTTIN_No: Code[20];
        Vend_State: Code[20];
        PlaceOfSupply: Text;
        MapleGSTIN: Code[20];
        recLoc: Record Location;//"14";
        recVen: Record Vendor;//"23";
        recGSTSetup: Record "GST Setup";//"16408";
        recPostedCRmemo: Record "Purch. Cr. Memo Hdr.";//"124";
        CrDocument: Text;
        CrDate: Date;
        recLoc1: Record Location;//"14";
        recVen1: Record Vendor;//"23";
        payterms1: Record "Payment Terms";//"3";
        RecVendor1: Record Vendor;//"23";
        CGSTAmt1: Decimal;
        CGSTRate1: Decimal;
        GSTComponentCGST1: Text;
        SGSTAmt1: Decimal;
        SGSTRate1: Decimal;
        GSTComponentSGST1: Text;
        IGSTAmt1: Decimal;
        IGSTRate1: Decimal;
        GSTComponentIGST1: Text;
        RecVendor2: Record Vendor;//"23";
        RecState2: Record State;// "13762";
        PlaceofSupply_CR: Text;
        IMEI_SERIAL_SHOW: Boolean;
        // RecFre: Record "13798"; //not found_kj
        Frt: Decimal;
        //  RecFre1: Record "13798";//not found_kj
        Frt1: Decimal;
        Category: code[30];
        itemRec: Record Item;

        //my
        GLacc: Record "G/L Account";
        name: Text[100];
        PostingG: Record "Vendor Posting Group";
        PostingDes: text[20];
        PostingDes2: text[20];
        Purchinvline: Record "Purch. Inv. Line";
        taxtransactionValue: Record "Tax Transaction Value";
        IGST: Decimal;
        SGST: Decimal;
        CGST: Decimal;
        TotalIGST: Decimal;
        TotalSGST: Decimal;
        TotalCGST: Decimal;
        Taxrecordid: RecordId;
        IGSTRATE: Decimal;
        CGSTRATE: Decimal;
        SGSTRATE: Decimal;
        Total: Decimal;
        Grandtotal: Decimal;

        //Detail
        Satename: Text[100];
        StateCode: text[50];
        // Total: Decimal;

        // compinfo: Record "Company Information";
        GSTDetailLegers: Record "Detailed GST Ledger Entry";
        CGSTAmts: Decimal;
        // CGSTRate: Decimal;
        GSTComponentCGSTs: Code[20];
        SGSTAmts: Decimal;
        // SGSTRate: Decimal;
        GSTComponentSGSTs: Code[20];
        IGSTAmts: Decimal;
        text1: Text[10];
        // IGSTRate: Decimal;

        GSTComponentIGSTs: Code[20];
        Amount: Decimal;
        Total_Amount: Decimal;
        // repcheck: report Check;
        AmountInWords: Text[200];
        wordsinarray: array[2] of text;
        Final_Amount: Decimal;
        Address1: Text[50];
        Address2: Text[50];
        City: Text[50];
        PostCode: Text[50];
        countryCode: Text[50];
        PostedVoucherRep: Report "Posted Voucher";
        totalRate: Integer;
        GstGroup: Record "GST Group";
        GST12: text[10];
        recstate: Record State;
        recStateDesc: Text[100];
        PurcCrMemoheadr: Record "Purch. Cr. Memo Hdr.";
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        doc: Code[100];
        doccr: Code[100];

        "BC Document Type": Code[100];
        BC_Document_TypeCR: Code[100];
        Vendor_Name: Text[100];
        Gstno: Code[50];
        Vedor_PostingGrp: Code[50];
        Location_State_Code: Code[50];
        Vendor_Invoice_No: Code[35];
        Posting_Date: Date;
        Procurement_Type: Code[50];
        Place_of_Supply: Text[100];
        Client_G_L_Account_No: Code[10];
        Description: Text[120];
        HSN: code[20];
        Classification: Text[120];
        Eligibility: Code[120];
        // GSTCode: Code[20];
        // RCM: text[120];
        // Taxable_Value: Decimal;
        // Integrated_tax: Decimal;
        // Central_Tax: Decimal;
        // State_Tax: Decimal;
        Total_Invoice: Decimal;
        BC_DocumentType: text[20];
        fromdate: Date;
        Todate: Date;

    //documenttype:




}