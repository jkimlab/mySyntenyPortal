#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;

my $svg_F = shift;
my $out_dir = shift;

my $base = basename($svg_F,".svg");
my $out_F = "$out_dir/$base.event.svg";
my $chr_id = 0;
my $chr_flag = 0;
my $element = "";
my @save_print = ();
my %hs;
open(W,">$out_F");
open(F,"tail -n +3 $svg_F|");
while(<F>)
{
	chomp;

	if($_ =~ /<svg/){
		$_ =~ s/<svg/<svg viewBox=\"40 40 715 715\"/g;
		print W "$_\n";
		next;
	}

	if($_ =~ /<g/ && $_ =~ /id=\"(\S+)\"/)
	{
		if($1 eq "plot0-axis")
		{
			my $line = <F>;
			next;
		}

		$element = $1;
		print W "$_\n";
		next;
	}
	
	if($_ =~ /<\/g/)
	{
		$element = "";
	}

	if($element eq "ideograms")
	{
		if($_ =~ /^<text/)
		{
			if($_ =~ />(\S+)<\/text>/)
			{
				$chr_id = $1;
			}

			foreach my $line (@save_print)
			{
				if($chr_flag == 0)
				{
					if($line =~ /width/ && $line =~ /fill:rgb\((\d+,\d+,\d+)\)/)
					{
						$hs{$1} = $chr_id;
					}

					if($chr_flag == 0)
					{
						$line =~ s/^<(\S+)/<$1 id=\"chr_id_$chr_id\" class=\"transforms\"/g;
					}
					print W "$line\n";
				}
			}
			
			if($chr_flag == 0)
			{
				$_ =~ s/^<(\S+)/<$1 id=\"chr_id_$chr_id\" class=\"transforms\"/g;
			}
			print W "$_\n";
			@save_print = ();
		}
		else
		{
			if($_ =~ /^<line/)
			{
				if($chr_flag == 0)
				{
					$_ =~ s/^<(\S+)/<$1 id=\"chr_id_$chr_id\" class=\"transforms\"/g;
				}
				print W "$_\n";

			}
			elsif($_ =~ /^<path/)
			{
				if($_ =~ /width/ && $_ =~ /fill:rgb\((\d+,\d+,\d+)\)/)
				{
					if($1 eq "255,255,255")
					{
						$chr_flag++;
						foreach my $line (@save_print)
						{
							print W "$line\n";
						}
						print W "$_\n";
						@save_print = ();
					}
					else
					{
						if($chr_flag != 0)
						{
							print W "$_\n";
						}
						else
						{
							push(@save_print,"$_");
						}
					}
				}
				else
				{
					if($chr_flag != 0)
					{
						print W "$_\n";
					}
					else
					{
						if($_ =~ /fill:none/)
						{
							$_ =~ s/^<(\S+)/<$1 id=\"chr_id_$chr_id\" class=\"transforms\"/g;
							print W "$_\n";
						}
						else
						{
							push(@save_print,"$_");
						}
					}
				}
			}
		}
	}
	elsif($element eq "track_0")
	{
		if($_ =~ /rgb\((\d+,\d+,\d+)\)/)
		{
			my $chr_id = $hs{$1};
			$_ =~ s/^<(\S+)/<$1 id=\"chr_id_$chr_id\" class=\"transforms_path\"/g;
			print W "$_\n";
		}
	}
	elsif($element eq "plot0")
	{
		if($_ =~ /rgb\((\d+,\d+,\d+)\)/)
		{
			my $chr_id = $hs{$1};
			$_ =~ s/^<(\S+)/<$1 id=\"chr_id_$chr_id\"/g;
			print W "$_\n";
		}
	}
	else
	{
		print W "$_\n";
	}
}
close(F);
close(W);
