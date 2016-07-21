#!/usr/bin/perl

use strict;

my $nation;
my $abb;
my $grade = {};
my $gold = {};
my $grade_continent = {};
my $gold_continent = {};
my $grade_year = {};
my $gold_year = {};

open FILE, "<olympic_nation.csv";
while (<FILE>) {
    my @raw = split(',', $_);
    chomp($raw[2]);
    $nation->{$raw[0]} = { 'name' => $raw[1], 'continent' => $raw[2] };
    $abb->{$raw[1]} = { 'abbreviation' => $raw[0], 'continent' => $raw[2] };
}
close FILE;

for my $f (keys %$abb) {
    #print $f. ": ". $abb->{$f}->{'abbreviation'}."\n";
}

my $year;
open FILE, ">olympic.csv";
for my $current (glob("all.csv")) {
    open CUR, $current;
    while (<CUR>) {
        my @r = split(',', $_);
        chomp($r[6]);
        $r[6] =~ s/^\s//;
        $r[6] =~ s/\s$//;
        $r[6] =~ s/\r$//;
        if ($r[3] =~ /^(\d{4})/) {
            $year = $1;
        }

        if ($r[6] =~ /[A-Z]{3}/) {
            $r[7] = $r[6];
            if (exists $nation->{$r[6]}) {
                $r[8] = $nation->{$r[6]}->{'continent'};
                $r[6] = $nation->{$r[6]}->{'name'};
            } else {
                print "$r[6] is npt in the mapping table.\n";
            }
        } elsif ($r[6] and $r[6] =~ /[\w ]+/) {
            if (exists $abb->{$r[6]}) {
                $r[8] = $abb->{$r[6]}->{'continent'};
                $r[7] = $abb->{$r[6]}->{'abbreviation'};
            }
        } else {
            next;
        }
        my $point;
        if ($r[4] == 1) { 
            $point = 3;  
            print "$r[6]\n";
            $gold->{$r[0]}->{$r[6]}++;
            $gold_continent->{$r[0]}->{$r[8]}++;
            $gold_year->{$r[0]}->{$year}->{$r[6]}++;
        } elsif ($r[4] == 3) { $point = 1 } else { $point = 2 }
        $grade->{$r[0]}->{$r[6]} += $point;
        $grade_continent->{$r[0]}->{$r[8]} += $point;
        $grade_year->{$r[0]}->{$year}->{$r[6]} += $point;
        my $new = join(',', @r) . "\n" unless ($r[3] =~ /2016/);
        print FILE "$new";
    }
}
close FILE;

open GRADE, ">nation_grade.csv";
open GOLD, ">nation_gold.csv";
for my $item (keys %$grade) {
    for my $country (keys %{$grade->{$item}}) {
        print GRADE "$item, $country, $grade->{$item}->{$country}\n";
        print GOLD "$item, $country, $gold->{$item}->{$country}\n" if ($gold->{$item}->{$country});
        #print "gold: ".$item.":".$country."-".$gold->{$item}->{$country}."\n";
    }
}
open GRADE_CONTINENT, ">continent_grade.csv";
open GOLD_CONTINENT, ">continent_gold.csv";
for my $item (keys %$grade_continent) {
    for my $continent (keys %{$grade_continent->{$item}}) {
        print GRADE_CONTINENT "$item, $continent, $grade_continent->{$item}->{$continent}\n";
        print GOLD_CONTINENT "$item, $continent, $gold_continent->{$item}->{$continent}\n" if ($gold_continent->{$item}->{$continent});
        #print "gold: ".$item.":".$country."-".$gold->{$item}->{$country}."\n";
    }
}

open GRADE_YEAR, ">year_grade.csv";
open GOLD_YEAR, ">year_gold.csv";
for my $item (keys %$grade_year) {
    for my $year (keys %{$grade_year->{$item}}) {
        for my $country (keys %{$grade_year->{$item}->{$year}}) {
            print GRADE_YEAR "$item, $year, $country, $grade_year->{$item}->{$year}->{$country}\n";
            print GOLD_YEAR "$item, $year, $country, $gold_year->{$item}->{$year}->{$country}\n" if ($gold_year->{$item}->{$year}->{$country});
            #print "gold: ".$item.":".$country."-".$gold->{$item}->{$country}."\n";
        }
    }
}