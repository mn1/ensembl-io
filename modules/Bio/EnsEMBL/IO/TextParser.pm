=pod

=head1 LICENSE

  Copyright (c) 1999-2013 The European Bioinformatics Institute and
  Genome Research Limited.  All rights reserved.

  This software is distributed under a modified Apache license.
  For license details, please see

  http://www.ensembl.org/info/about/code_licence.html

=head1 NAME

TextParser - An abstract line by line parser class

=cut

package Bio::EnsEMBL::IO::TextParser;

use strict;
use warnings;

use Bio::EnsEMBL::Utils::Exception qw/throw/;
use Bio::EnsEMBL::Utils::Scalar qw/assert_ref/;

use base qw/Bio::EnsEMBL::IO::Parser/;

=head2 open

    Constructor
    Argument [1] : Filepath
    Argument [2+]: Hash of parameters for configuration, e.g. buffer sizes or 
                   specific functions for handling headers or data
    Returntype   : Bio::EnsEMBL::IO::TextParser

=cut

sub open {
    my $caller = shift;
    my $filename = shift;
    my $class = ref($caller) || $caller;
    
    my $self = $class->SUPER::new(@_);
    $self->{'filename'} = $filename;
    open $self->{'filehandle'} $filename || throw("Could not open " . $filename);
    
    return $self;
}

=head2 close
    Description  : Closes the filehandler
    Returntype   : True/False on success/failure
=cut

sub close {
    my $self = shift;
    return close $self->{'filehandle'};
}

=head2 read_block
    Arg [1]     : IO::TextParser object
    Description : Reads a line of text, stores it into next_block, 
    		  moving next_block to current_block.
    Returntype   : True/False on existence of a defined current_block after running.
=cut

sub read_block {
    my $self = shift;

    my $fh = $self->{'filehandle'};
    my $new_line;
    if (!eof($fh)) {
        $new_line = <$fh> || throw ("Error reading file handle: $!");   
    }    
    if defined $new_line {
	chomp $new_line;
        $self->{'next_line'} = $new_line;
    }
}

1;