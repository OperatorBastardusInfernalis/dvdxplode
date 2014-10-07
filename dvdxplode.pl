#!/usr/bin/perl -w

use strict;

use DVD::Read;
use Time::HiRes;

$| = 1;  # Autoflush stdout.

my $progresstime;
sub startprogress($) {
	my ($msg) = @_;
	print STDERR "$msg\n\e[K";
	$progresstime = Time::HiRes::time();
}

sub progress($$$$) {
	my ($cell, $cell_total, $block, $block_total) = @_;
	my $t = Time::HiRes::time();
	if ($t >= $progresstime) {
		print STDERR "Reading block $block/$block_total\e[K\r";
		$progresstime = $t + 0.1;
	}
}

sub endprogress($) {
	my ($msg) = @_;
	print STDERR "$msg\e[K\n";
	undef $progresstime;
}

sub xtitles($$) {
	my ($dvd, $pattern) = @_;
	for my $title(1..$dvd->titles_count()) {
		my $t = $dvd->get_title($title);
		if (!$t) {
			warn "Could not open DVD title $t: $!";
			next;
		}
		my $f = sprintf($pattern, $title);
		startprogress "Extracting title $title to $f...";
		$t->extract($f, \&progress);
		endprogress "Done.";
		print "$f\n";
	}
}

sub xchapters($$) {
	my ($dvd, $pattern) = @_;
	for my $title(1..$dvd->titles_count()) {
		my $t = $dvd->get_title($title);
		if (!$t) {
			warn "Could not open DVD title $t: $!";
			next;
		}
		for my $chapter(1..$t->chapters_count()) {
			my $f = sprintf($pattern, $title, $chapter);
			startprogress "Extracting title $title chapter $chapter to $f...";
			$t->extract_chapter($chapter, $f, \&progress);
			endprogress "Done.";
			print "$f\n";
		}
	}
}

my ($dvdpath, $pattern) = @ARGV;

if (defined $pattern && $pattern =~ /%/) {
	my $dvd = DVD::Read->new($dvdpath)
		or die "Could not open DVD: $!";
	if ($pattern =~ /%.*%/) {
		xchapters($dvd, $pattern);
	} else {
		xtitles($dvd, $pattern);
	}
} else {
	die "Usage: $0 /path/to/dvd.iso <title%d.vob|title%d-chapter%d.vob>\n";
}
