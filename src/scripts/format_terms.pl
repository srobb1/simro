#!/usr/bin/perl
use strict;
use warnings;
use Data::Dumper;

=pod
=head1 split pattern tsv on object Properties

=item splits the objectProperites that start at column $prop_start into separate TSVs

=item a new pattern will be needed for each new TSV. This pattern only needs the relation, classand var declaration for the objProp value (ie part_of), and the subclass of description.

=item essentially the term gets added first from the plana_terms.yaml and is modified with these objectProp expansion patterns
 
=item pattern.yaml example

pattern_name: plana_terms_part_of.yaml
pattern_iri: https://tbd
description: "adding ObjectProperty:part_of to PLANA terms"

contributors:
  - https://orcid.org/0000-0002-3528-5267

relations:
  part of: BFO:0000050

classes:
  part_of: BFO:0000040

vars:
  part_of: "'part_of'"

subClassOf:
    text: "'part of' some  %s"
    vars:
      - part_of

=cut

# perl format_terms.pl SIMRO usedByMethod terms.tsv
my $prefix = shift; #SIMRO
my $prop_start_label = shift; #usedByMethod
$prop_start_label = defined $prop_start_label ? $prop_start_label : 'part_of';
my $tsv = shift;
open TSV, $tsv or die "Cant open input term tsv: $tsv $!\n";

my $header = <TSV>;
chomp $header;
my $prop_start;
my $parent_start;
my %onto_terms;

my @headers = split "\t" , $header;
for (my $i=0; $i<@headers ; $i++){
  if ($headers[$i] eq $prop_start_label){
    $prop_start = $i;
  }elsif($headers[$i] eq 'entity' ){
    $parent_start = $i;
  }
}
print "parent start=$parent_start\n";
print "@headers\n";
my %props;
my %terms;
while (my $line = <TSV>){
  next if $line =~/^\s*$/;
  chomp $line;
  my @line = split /\t/, $line;
  my ($patterned,$term_id,$term_label) = @line;
  next if $patterned ne 'none';
  $term_id =~s/^\s+//;
  $term_id =~s/\s+$//;
  $term_label =~s/^\s+//;
  $term_label =~s/\s+$//;
  if (defined $term_id){
    $terms{$term_id}=$term_label;
  }

  my @parent_ids = split /\s*\|\s*/ , $line[$parent_start];
  my @parent_labels = split /\s*\|\s*/ , $line[$parent_start+1];
  for (my $i=0; $i<@parent_ids; $i++){
    for (my $j=1 ; $j<$prop_start ; $j++){
      if ($j == $parent_start){
        push @{$onto_terms{$term_id}{$parent_ids[$i]}},$parent_ids[$i];
      }
      elsif ($j == $parent_start+1){
        push @{$onto_terms{$term_id}{$parent_ids[$i]}},$parent_labels[$i];

      }else{
        if (defined $line[$j]){
          push @{$onto_terms{$term_id}{$parent_ids[$i]}},$line[$j];
        }else{
          #warn "PROBLEMS HERE with uninitialized columns: {$term_id}{$parent_ids[$i]}\n";
          push @{$onto_terms{$term_id}{$parent_ids[$i]}},'';
        }
      }
    }
  }
#print Dumper \%onto_terms;
  
  for(my $i=$prop_start; $i < @line; $i+=2){
    $line[$i] =~ s/^\s+//;
    $line[$i] =~ s/\s+$//;
    $line[$i+1] =~ s/^\s+//;
    $line[$i+1] =~ s/\s+$//;
    my @ids = split /\s*\|\s*/, $line[$i];
    my @labels = split /\s*\|\s*/, $line[$i+1];
    warn "$term_id:$term_label $headers[$i] has unequal pairing of prop ids and labels" if scalar @ids != scalar @labels;
    for (my $j=0; $j<@ids; $j++){
      my $id = $ids[$j];
      my $label = $labels[$j];
      #$id =~s/^\s+//;
      #$id =~s/\s+$//;
      #$label =~s/^\s+//;
      #$label =~s/\s+$//;
      $props{$headers[$i]}{$term_id}{$ids[$j]}=$labels[$j];
    }
  } 
} 
#print Dumper \%props;
my $outfile = $prefix . "_terms.tsv"; 
open MAIN_OUT, ">$outfile" or die "Can't open $outfile for writing\n";
## print header line
my @out_headers;
for (my $i = 1; $i<$prop_start; $i++){
  push @out_headers, $headers[$i];
}
print MAIN_OUT  join("\t",@out_headers),"\n";
## end print header line

foreach my $term_id (sort keys %onto_terms){ 
  foreach my $parent_id (sort keys %{$onto_terms{$term_id}}){
    print MAIN_OUT join ("\t",@{$onto_terms{$term_id}{$parent_id}}),"\n";
  }
}

foreach my $prop (sort keys %props){
  my $sub_out = $prefix . "_terms_" . $prop . ".tsv"; 
  open OUT, ">$sub_out" or die "Can't open $sub_out for writing\n";
  print OUT join("\t",$headers[1],$headers[2],$prop,$prop."_label"),"\n";
  foreach my $term_id(sort keys %{$props{$prop}}){
    next if !scalar keys %{$props{$prop}{$term_id}};
    foreach my $prop_id(keys %{$props{$prop}{$term_id}}){
      print OUT join("\t", $term_id,$terms{$term_id},$prop_id,$props{$prop}{$term_id}{$prop_id}),"\n";
    }
  }
  close OUT;
}
#print Dumper \%props;
