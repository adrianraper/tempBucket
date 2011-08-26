#!user/bin/perl -w

print "Please enter the file path: ";
my $xmlFilePath;
my $outputFilePath;

#$xmlFilePath= "D:/flash progress/ampie/" . chomp(<STDIN>);

chomp($xmlFilePath  =<STDIN>);

if(!$xmlFilePath =~ /.xml/){
  $xmlFilePath .= ".xml";
}

$outputFilePath = $xmlFilePath;
$outputFilePath =~ s/.xml/_output.xml/;

open FILE, "<", "$xmlFilePath"
  or die "Can't open '$xmlFilePath':$!";

open OUTFILE, "+>", "$outputFilePath"
  or die "Can't create file";

#my $replaceQuote  = "haha";
my $resultStr= "";
while(<FILE>){ 
  $_ =~ s/ *(<!--).*//g;     # delete comments
  $_ =~ s/"/\\"/g;              # change the " to \"
  $_ =~ s/\n//;                 # delete newlines
  $_ =~ s/( *|\t*)</</;     # erase all blanks before <
  $_ =~ s/>( *|\t*)/>/;     # erase all blanks after >
  $resultStr .= $_;
}

print "Outputting to $outputFilePath...";
print OUTFILE "\"$resultStr\"";
close(FILE);
close(OUTFILE);

print "\n - Press any key to quit the program -\n";
<STDIN>;
