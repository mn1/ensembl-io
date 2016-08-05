=head1 LICENSE

Copyright [1999-2016] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

=head1 NAME

Bio::EnsEMBL::IO::Writer::GFF3 - Generic GFF3 Writer

=head1 SYNOPSIS

  use Bio::EnsEMBL::IO::Writer::GFF3;

  my $writer = Bio::EnsEMBL::IO::Writer::GFF3->new($translator);

  $writer->write($object);

=head1 Description

  Write records out in GFF3 format. The module uses a translator given
  at creation time which knows how to interrogate a specified type
  of feature/object that will be passed in to the write function.

  As in, for the GFF3 format the translator must know how to retrieve
  seqname, source, type, start, end, score, strand, phase and attributes
  fromt he objects you plan to feed the writer.

=cut

package Bio::EnsEMBL::IO::Writer::GFF3;

use base qw/Bio::EnsEMBL::IO::Writer::ColumnBasedGeneric/;

use strict;
use warnings;
use Carp;

use Bio::EnsEMBL::IO::Object::GFF3;
use Bio::EnsEMBL::IO::Object::GFF3Metadata;

my @default_order = qw(ID Parent Name Alias Target Gap Derives_from Note Dbxref Ontology_term Is_circular);

=head2 new

    Description: Constructor for a column based generic writer
    Args[1]    : Translator object for the type of object being written 
                 (ie. for Ensembl Features, etc)

=cut

sub new {
    my $class = shift;
    my $translator = shift;

    my $self = $class->SUPER::new($translator);

    $self->fields( Bio::EnsEMBL::IO::Object::GFF3->fields() );

    if( $translator->can('strand_conversion') ) {
	$translator->strand_conversion(Bio::EnsEMBL::IO::Object::GFF3->strand_conversion());
    }

    # Cheat and make a GFF3Metadata object in a really quick and lighttweight manner.
    # We need one hanging around for the fwd-ref writer call
    $self->{fwd_ref} = bless { type => 'fwd-ref-delimeter' }, 'Bio::EnsEMBL::IO::Object::GFF3Metadata';

    return $self;
}

=head2 fwd_ref_delimeter

    Description: Shortcut to write a forward reference delimeter in the GFF3 format,
                 ie. ###

=cut

sub fwd_ref_delimeter {
    my $self = shift;

    $self->write( $self->{fwd_ref} );
}

=head2 create_record

    Description: Create the record in GFF3 to write out to the file
    Args[1]    : Object to format
    Returntype : String

=cut

sub create_record {
    my $self = shift;
    my $object = shift;

    my @values = $self->{translator}->batch_fields($object, $self->fields());

    # Special case to handle attributes field and it's ordering
#    my $attr = pop @values;
    # We get the attribute values back as an arrayref, combine the ordered list
    # using the GFF3 style '; ' delimiter and push back on to the values
#    $attr = $self->concatenate_fields($attr, '; ');
#    push @values, $attr;

    return $self->concatenate_fields(\@values), "\n";
    
}

=head2 combine_fields

    Description: For fields that are composite fields (ie. attributes in
                 GFF3), combine the pieces of the field using the correct
                 delimiters for GFF3
    Returntype : String of concatenated fields

=cut

sub combine_fields {
    my $self = shift;
    my $values = shift;

    my $order = $self->attributes_order();
    if($order) {
	my %seen;
	@seen{@{$order}} = ();
	my @attrs = (@{$order}, grep{!exists $seen{$_}} sort keys %{$values});
	$order = \@attrs;
    }

    return $self->SUPER::combine_fields($values, $order);
}

sub attributes_order {
    my $self = shift;
    my $order = shift;

    if($order) {
	@default_order = @{$order};
    }

    return \@default_order;
}

sub clear_attributes_order {
    my $self = shift;

    @default_order = undef;
}

1;