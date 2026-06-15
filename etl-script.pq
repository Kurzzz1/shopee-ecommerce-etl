let
    Source = Csv.Document(File.Contents("C:\Users\Laptop\Downloads\shopee (1).csv"),[Delimiter=",", Columns=17, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Promoted Headers" = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    #"Changed Type" = Table.TransformColumnTypes(#"Promoted Headers",{{"contents href", type text}, {"inset-y-0 src", type text}, {"w-full src", type text}, {"line-clamp-2", type text}, {"mr-0 src", type text}, {"font-medium 2", Int64.Type}, {"h-4", Percentage.Type}, {"truncate", type text}, {"flex-none src", type text}, {"flex-none", type number}, {"truncate 2", type text}, {"pointer-events-none src", type text}, {"truncate 3", type text}, {"inline src", type text}, {"ml-[3px]", type text}, {"875rem] href", type text}, {"truncate 4", type text}}),
    #"Removed Columns" = Table.RemoveColumns(#"Changed Type",{"w-full src"}),
    #"Renamed Columns" = Table.RenameColumns(#"Removed Columns",{{"inset-y-0 src", "Product Photo"}, {"contents href", "Product Link"}, {"line-clamp-2", "Product Name"}}),
    #"Removed Columns1" = Table.RemoveColumns(#"Renamed Columns",{"mr-0 src"}),
    #"Renamed Columns1" = Table.RenameColumns(#"Removed Columns1",{{"font-medium 2", "Price"}, {"truncate", "Offers"}, {"h-4", "Discounted Price"}}),
    #"Removed Columns2" = Table.RemoveColumns(#"Renamed Columns1",{"flex-none src", "pointer-events-none src", "inline src", "875rem] href"}),
    #"Capitalized Each Word" = Table.TransformColumns(#"Removed Columns2",{{"Product Name", Text.Proper, type text}}),
    #"Inserted Text After Delimiter" = Table.AddColumn(#"Capitalized Each Word", "Text After Delimiter", each Text.AfterDelimiter([Product Name], "】"), type text),
    #"Reordered Columns" = Table.ReorderColumns(#"Inserted Text After Delimiter",{"Product Link", "Product Photo", "Product Name", "Text After Delimiter", "Price", "Discounted Price", "Offers", "flex-none", "truncate 2", "truncate 3", "ml-[3px]", "truncate 4"}),
    #"Removed Columns3" = Table.RemoveColumns(#"Reordered Columns",{"Text After Delimiter"}),
    #"Inserted Text After Delimiter1" = Table.AddColumn(#"Removed Columns3", "Text After Delimiter", each Text.AfterDelimiter([Product Name], "】"), type text),
    #"Reordered Columns1" = Table.ReorderColumns(#"Inserted Text After Delimiter1",{"Product Link", "Product Photo", "Product Name", "Text After Delimiter", "Price", "Discounted Price", "Offers", "flex-none", "truncate 2", "truncate 3", "ml-[3px]", "truncate 4"}),
    #"Renamed Columns2" = Table.RenameColumns(#"Reordered Columns1",{{"Text After Delimiter", "Product Name Heto"}}),
    #"Replaced Blank - NA" = Table.ReplaceValue(#"Renamed Columns2","","NA",Replacer.ReplaceValue,{"Product Name Heto"}),
    #"Replaced NA - Null" = Table.ReplaceValue(#"Replaced Blank - NA","NA",null,Replacer.ReplaceValue,{"Product Name Heto"}),
    #"Final Product name" = Table.AddColumn(#"Replaced NA - Null", "Custom", each if [Product Name Heto] = null then [Product Name]
else [Product Name Heto]),
    #"Reordered Final Product Name" = Table.ReorderColumns(#"Final Product name",{"Product Link", "Product Photo", "Product Name", "Product Name Heto", "Custom", "Price", "Discounted Price", "Offers", "flex-none", "truncate 2", "truncate 3", "ml-[3px]", "truncate 4"}),
    #"Remove Text After Delimeter for Product" = Table.RemoveColumns(#"Reordered Final Product Name",{"Product Name Heto", "Product Name"}),
    #"Renamed Final Product Name to Product Name" = Table.RenameColumns(#"Remove Text After Delimeter for Product",{{"Custom", "Product Name"}}),
    #"Remove the Sticker on One Row" = Table.ReplaceValue(#"Renamed Final Product Name to Product Name","✅","100% Original Meet P47 Bluetooth Headphone Wireless Mp3/Fm/Bass",Replacer.ReplaceText,{"Product Name"}),
    #"Renamed Columns3" = Table.RenameColumns(#"Remove the Sticker on One Row",{{"Discounted Price", "Discount"}, {"Offers", "Shop Offers"}}),
    #"Formal Text for Product and Shop Offers" = Table.TransformColumns(#"Renamed Columns3",{{"Shop Offers", Text.Proper, type text}, {"Product Name", Text.Proper, type text}}),
    #"Offers: Blank -  NA" = Table.ReplaceValue(#"Formal Text for Product and Shop Offers","","NA",Replacer.ReplaceValue,{"Shop Offers"}),
    #"Renamed Column to Ratings" = Table.RenameColumns(#"Offers: Blank -  NA",{{"flex-none", "Ratings"}}),
    #"Filtered Rows" = Table.SelectRows(#"Renamed Column to Ratings", each true),
    #"Renamed Columns4" = Table.RenameColumns(#"Filtered Rows",{{"truncate 3", "Delivery Period"}, {"ml-[3px]", "Location"}, {"truncate 4", "Other Shop Offers"}, {"truncate 2", "Sold"}}),
    #"Added Custom" = Table.AddColumn(#"Renamed Columns4", "True Ratings", each if [Ratings] = null then List.Median(#"Renamed Columns4"[Ratings])
else [Ratings]),
    #"Reordered Columns2" = Table.ReorderColumns(#"Added Custom",{"Product Link", "Product Photo", "Product Name", "Price", "Discount", "Shop Offers", "Ratings", "True Ratings", "Sold", "Delivery Period", "Location", "Other Shop Offers"}),
    #"Filtered Rows1" = Table.SelectRows(#"Reordered Columns2", each ([Sold] <> "")),
    #"Added Custom1" = Table.AddColumn(#"Filtered Rows1", "Cleaned ", each let
    // 1. Handle Nulls or empty cells first to avoid errors
    source = if [Sold] = null or [Sold] = "" then "0" else Text.Lower(Text.From([Sold])),
    
    // 2. Remove the "+" and "sold" (just in case it's still there)
    clean = Text.Trim(Text.Replace(Text.Replace(source, "+", ""), "sold", "")),
    
    // 3. Logic to multiply if 'k' exists
    result = if Text.Contains(clean, "k") then 
        Number.From(Text.Replace(clean, "k", ""), "en-US") * 1000 
    else 
        Number.From(clean, "en-US")
in
    result),
    #"Reordered Columns3" = Table.ReorderColumns(#"Added Custom1",{"Product Link", "Product Photo", "Product Name", "Price", "Discount", "Shop Offers", "Ratings", "True Ratings", "Sold", "Cleaned ", "Delivery Period", "Location", "Other Shop Offers"}),
    #"Changed Type1" = Table.TransformColumnTypes(#"Reordered Columns3",{{"Cleaned ", Int64.Type}}),
    #"Removed Columns4" = Table.RemoveColumns(#"Changed Type1",{"Sold"}),
    #"Replaced Value" = Table.ReplaceValue(#"Removed Columns4","",null,Replacer.ReplaceValue,{"Delivery Period"}),
    #"Added Custom2" = Table.AddColumn(#"Replaced Value", "hello", each if [Delivery Period] = null and Text.Contains([Shop Offers],"Today") then "0"
else if [Delivery Period] = null then "7-30"
else [Delivery Period]),
    #"Reordered Columns4" = Table.ReorderColumns(#"Added Custom2",{"Product Link", "Product Photo", "Product Name", "Price", "Discount", "Shop Offers", "Ratings", "True Ratings", "Cleaned ", "hello", "Delivery Period", "Location", "Other Shop Offers"}),
    #"Removed Orig Delivery Period" = Table.RemoveColumns(#"Reordered Columns4",{"Delivery Period"}),
    #"Renamed Delivery Period" = Table.RenameColumns(#"Removed Orig Delivery Period",{{"hello", "Delivery Period"}}),
    #"Capitalized Each Word1" = Table.TransformColumns(#"Renamed Delivery Period",{{"Delivery Period", Text.Proper, type text}}),
    #"Added Custom3" = Table.AddColumn(#"Capitalized Each Word1", "Custom", each if Text.Contains([Delivery Period], "Days") then Text.BeforeDelimiter([Delivery Period],"Days")
else if Text.Contains([Delivery Period], "Tomorrow")
then "1"
else [Delivery Period]),
    #"Reordered Columns5" = Table.ReorderColumns(#"Added Custom3",{"Product Link", "Product Photo", "Product Name", "Price", "Discount", "Shop Offers", "Ratings", "True Ratings", "Cleaned ", "Custom", "Delivery Period", "Location", "Other Shop Offers"}),
    #"Removed Columns5" = Table.RemoveColumns(#"Reordered Columns5",{"Delivery Period"}),
    #"Updated Delivery Period - purely numerical" = Table.RenameColumns(#"Removed Columns5",{{"Custom", "Delivery Period"}}),
    #"Min Delivery Period" = Table.AddColumn(#"Updated Delivery Period - purely numerical", "Min Delivery Period", each let 
val = Text.From([Delivery Period]),
min = if Text.Contains(val, "-")
      then Number.From(Text.BeforeDelimiter(val,"-"))
      else if Text.Contains(val,"<")
      then 1
      else Number.From(val)
in min),
    #"Reordered Columns6" = Table.ReorderColumns(#"Min Delivery Period",{"Product Link", "Product Photo", "Product Name", "Price", "Discount", "Shop Offers", "Ratings", "True Ratings", "Cleaned ", "Delivery Period", "Min Delivery Period", "Location", "Other Shop Offers"}),
    #"Max Delivery Period" = Table.AddColumn(#"Reordered Columns6", "Max Delivery Period", each let val = Text.From([Delivery Period]),
max = if Text.Contains(val,"-")
      then Number.From(Text.AfterDelimiter(val,"-"))
      else if Text.Contains(val,"<")
      then Number.From(Text.AfterDelimiter(val,"<"))
      else Number.From(val)
in max),
    #"Reordered Columns7" = Table.ReorderColumns(#"Max Delivery Period",{"Product Link", "Product Photo", "Product Name", "Price", "Discount", "Shop Offers", "Ratings", "True Ratings", "Cleaned ", "Delivery Period", "Min Delivery Period", "Max Delivery Period", "Location", "Other Shop Offers"}),
    #"Removed Interval Delivery Period" = Table.RemoveColumns(#"Reordered Columns7",{"Delivery Period"}),
    #"Capitalized Each Word2" = Table.TransformColumns(#"Removed Interval Delivery Period",{{"Location", Text.Proper, type text}}),
    #"Replaced Value2" = Table.ReplaceValue(#"Capitalized Each Word2","","Unknown",Replacer.ReplaceValue,{"Location"}),
    #"Added Custom4" = Table.AddColumn(#"Replaced Value2", "Custom", each let loc = Text.From([Location]),
city = if Text.Contains(loc,",")
       then Text.From(Text.BeforeDelimiter(loc,","))
       else Text.From([Location])
in city),
    #"Added Custom5" = Table.AddColumn(#"Added Custom4", "Custom.1", each let loc = Text.From([Location]),
city = if Text.Contains(loc,",")
       then Text.BeforeDelimiter(loc,",")
       else "Unknown"
in city),
    #"Removed Columns6" = Table.RemoveColumns(#"Added Custom5",{"Custom"}),
    #"Renamed Columns5" = Table.RenameColumns(#"Removed Columns6",{{"Custom.1", "City"}}),
    #"Filtered Rows3" = Table.SelectRows(#"Renamed Columns5", each true),
    #"Filtered Rows2" = Table.SelectRows(#"Filtered Rows3", each true),
    #"Replaced Value1" = Table.ReplaceValue(#"Filtered Rows2","","Unknown",Replacer.ReplaceValue,{"Location"}),
    #"Reordered Columns8" = Table.ReorderColumns(#"Replaced Value1",{"Product Link", "Product Photo", "Product Name", "Price", "Discount", "Shop Offers", "Ratings", "True Ratings", "Cleaned ", "Min Delivery Period", "Max Delivery Period", "Location", "City", "Other Shop Offers"}),
    #"Added Custom6" = Table.AddColumn(#"Reordered Columns8", "Region", each let loc = Text.From([Location]),
region = if Text.Contains(loc, ",")
         then Text.Proper(Text.AfterDelimiter(loc,","))
         else "Unknown"
in region),
    #"Reordered Columns9" = Table.ReorderColumns(#"Added Custom6",{"Product Link", "Product Photo", "Product Name", "Price", "Discount", "Shop Offers", "Ratings", "True Ratings", "Cleaned ", "Min Delivery Period", "Max Delivery Period", "Location", "City", "Region", "Other Shop Offers"}),
    #"Trimmed Text" = Table.TransformColumns(#"Reordered Columns9",{{"City", Text.Trim, type text}, {"Region", Text.Trim, type text}}),
    #"Added Custom7" = Table.AddColumn(#"Trimmed Text", "Country", each let loc = Text.From([Location]),
country = if Text.Contains(loc, "China")
          then "China"
          else if Text.Contains(loc,"Vietnam")
          then "Vietnam"
          else if Text.Contains(loc,",")
          then "Philippines"
          else if Text.Contains(loc, "Unknown")
          then "Unknown"
          else "Other Overseas"
in country),
    #"Reordered Columns10" = Table.ReorderColumns(#"Added Custom7",{"Product Link", "Product Photo", "Product Name", "Price", "Discount", "Shop Offers", "Ratings", "True Ratings", "Cleaned ", "Min Delivery Period", "Max Delivery Period", "Location", "City", "Region", "Country", "Other Shop Offers"}),
    #"Renamed Columns6" = Table.RenameColumns(#"Reordered Columns10",{{"Cleaned ", "Sold"}}),
    #"Removed Columns7" = Table.RemoveColumns(#"Renamed Columns6",{"Location"}),
    #"Changed Type2" = Table.TransformColumnTypes(#"Removed Columns7",{{"Price", Currency.Type}}),
    #"Filtered Rows4" = Table.SelectRows(#"Changed Type2", each true),
    #"Trimmed Text1" = Table.TransformColumns(#"Filtered Rows4",{{"Other Shop Offers", Text.Trim, type text}}),
    #"Capitalized Each Word3" = Table.TransformColumns(#"Trimmed Text1",{{"Other Shop Offers", Text.Proper, type text}}),
    #"Replaced Value3" = Table.ReplaceValue(#"Capitalized Each Word3","","No Additional Offer",Replacer.ReplaceValue,{"Other Shop Offers"}),
    #"Filtered Rows5" = Table.SelectRows(#"Replaced Value3", each true),
    #"Renamed Columns7" = Table.RenameColumns(#"Filtered Rows5",{{"Other Shop Offers", "Other  Offers"}}),
    #"Added Custom8" = Table.AddColumn(#"Renamed Columns7", "Other Offers Category", each let off = [Other  Offers],
offers = if Text.Contains(off, "Gift")
         then "Gift/Bonus"
         else if Text.Contains(off, "Enjoy")
         then "Discount/Bundle"
         else if Text.Contains(off, "Shipping")
         then "Logistic Perk"
         else if Text.Contains(off, "Wholesale")
         then "Bulk"
         else "No Additional Offer"
in offers),
    #"Changed Type3" = Table.TransformColumnTypes(#"Added Custom8",{{"Other Offers Category", type text}, {"Country", type text}, {"Max Delivery Period", Int64.Type}, {"Min Delivery Period", Int64.Type}}),
    #"Removed Columns8" = Table.RemoveColumns(#"Changed Type3",{"Ratings"}),
    #"Renamed Columns8" = Table.RenameColumns(#"Removed Columns8",{{"True Ratings", "Ratings"}}),
    #"Reordered Columns11" = Table.ReorderColumns(#"Renamed Columns8",{"Product Link", "Product Photo", "Product Name", "Price", "Discount", "Shop Offers", "Other  Offers", "Other Offers Category", "Ratings", "Sold", "Min Delivery Period", "Max Delivery Period", "City", "Region", "Country"}),
    #"Filtered Rows6" = Table.SelectRows(#"Reordered Columns11", each true),
    #"Replaced Value4" = Table.ReplaceValue(#"Filtered Rows6","NA","No Additional Offer",Replacer.ReplaceText,{"Shop Offers"}),
    #"Shops Offer Category" = Table.AddColumn(#"Replaced Value4", "Shop Offers Category", each let offe = [Shop Offers],
offers = if Text.Contains(offe, "Any")
         and Text.Contains(offe, "Enjoy")
         or Text.Contains(offe, "Wholesale")
         then "Discount/Bundle"
         else if Text.Contains(offe,"%")
         and Text.Contains(offe, "Off")
         then "Percentage Voucher"
         else if Text.Contains(offe, "Off")
         and Text.Contains(offe, "₱" )
         then "Fixed Rebate"
         else if Text.Contains(offe, "Cashback")
         then "Cashback"
         else if Text.Contains(offe, "Add-on")
         or Text.Contains(offe, "Deal" )
         then "Add-on/Deal"
         else if Text.Contains(offe, "Today Only")
         then "Flash Sale"
         else if Text.Contains(offe, "Fast Shipping")
         or Text.Contains(offe, "Today")
         then "Logistic Perk"
         else if Text.Contains(offe, "Free Gift")
         then "Gift/Bonus"
         else if Text.Contains(offe, "No Additional Offer")
         then "No Additional Offer"
         else "Others"
in offers),
    #"Reordered Columns12" = Table.ReorderColumns(#"Shops Offer Category",{"Product Link", "Product Photo", "Product Name", "Price", "Discount", "Shop Offers", "Shop Offers Category", "Other  Offers", "Other Offers Category", "Ratings", "Sold", "Min Delivery Period", "Max Delivery Period", "City", "Region", "Country"}),
    #"Filtered Rows7" = Table.SelectRows(#"Reordered Columns12", each ([Discount] <> null and [Discount] <> -0.49 and [Discount] <> -0.48 and [Discount] <> -0.47 and [Discount] <> -0.46 and [Discount] <> -0.45 and [Discount] <> -0.44 and [Discount] <> -0.43 and [Discount] <> -0.42 and [Discount] <> -0.41 and [Discount] <> -0.4 and [Discount] <> -0.39 and [Discount] <> -0.38 and [Discount] <> -0.37 and [Discount] <> -0.36 and [Discount] <> -0.35 and [Discount] <> -0.34 and [Discount] <> -0.33 and [Discount] <> -0.3 and [Discount] <> -0.29 and [Discount] <> -0.28 and [Discount] <> -0.27 and [Discount] <> -0.26 and [Discount] <> -0.25 and [Discount] <> -0.23 and [Discount] <> -0.22 and [Discount] <> -0.19 and [Discount] <> -0.18 and [Discount] <> -0.16 and [Discount] <> -0.13 and [Discount] <> -0.12 and [Discount] <> -0.11 and [Discount] <> -0.1 and [Discount] <> -0.08 and [Discount] <> -0.07 and [Discount] <> -0.06 and [Discount] <> -0.03)),
    #"Added Custom9" = Table.AddColumn(#"Filtered Rows7", "Discount Category", each let
discategory = Number.Abs([Discount]),
discount = if discategory <= 0.10 then "Minor"
           else if discategory <= 0.35 then "Standard"
           else if discategory <= 0.60 then "Aggressive"
           else "Inflated"
in discount),
    #"Reordered Columns13" = Table.ReorderColumns(#"Added Custom9",{"Product Link", "Product Photo", "Product Name", "Price", "Discount", "Discount Category", "Shop Offers", "Shop Offers Category", "Other  Offers", "Other Offers Category", "Ratings", "Sold", "Min Delivery Period", "Max Delivery Period", "City", "Region", "Country"}),
    #"Filtered Rows8" = Table.SelectRows(#"Reordered Columns13", each true),
    #"Added Custom10" = Table.AddColumn(#"Filtered Rows8", "Approx Anchor Price", each Number.Round([Price]/(1-Number.Abs([Discount])),0)),
    #"Reordered Columns14" = Table.ReorderColumns(#"Added Custom10",{"Product Link", "Product Photo", "Product Name", "Approx Anchor Price", "Price", "Discount", "Discount Category", "Shop Offers", "Shop Offers Category", "Other  Offers", "Other Offers Category", "Ratings", "Sold", "Min Delivery Period", "Max Delivery Period", "City", "Region", "Country"}),
    #"Changed Type4" = Table.TransformColumnTypes(#"Reordered Columns14",{{"Approx Anchor Price", Currency.Type}, {"Discount Category", type text}, {"Shop Offers Category", type text}, {"Ratings", type number}}),
    #"Filtered Rows9" = Table.SelectRows(#"Changed Type4", each true)
in
    #"Filtered Rows9"
