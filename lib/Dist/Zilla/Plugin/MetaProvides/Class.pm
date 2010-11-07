use strict;
use warnings;

package Dist::Zilla::Plugin::MetaProvides::Class;
BEGIN {
  $Dist::Zilla::Plugin::MetaProvides::Class::VERSION = '1.12044910';
}

# ABSTRACT: Scans Dist::Zilla's .pm files and tries to identify classes using Class::Discover.

# $Id:$
use Moose;
use Moose::Autobox;
use Class::Discover ();

use Dist::Zilla::MetaProvides::ProvideRecord;


use namespace::autoclean;
with 'Dist::Zilla::Role::MetaProvider::Provider';


has '+meta_noindex' => ( default => sub { 1 } );


sub provides {
  my $self        = shift;
  my $perl_module = sub { $_->name =~ m{^lib\/.*\.(pm|pod)$} };
  my $get_records = sub {
    $self->_classes_for( $_->name, $_->content );
  };

  return $self->_apply_meta_noindex( $self->zilla->files->grep($perl_module)->map($get_records)->flatten );
}


sub _classes_for {
  my ( $self, $filename, $content ) = @_;
  my ($scanparams) = {
    keywords => { class => 1, role => 1, },
    files    => [$filename],
    file     => $filename,
  };
  my $to_record = sub {
    Dist::Zilla::MetaProvides::ProvideRecord->new(
      module  => $_->keys->at(0),
      file    => $filename,
      version => $_->values->at(0)->{version},
      parent  => $self,
    );
  };

  # I'm being bad and using a private function, but meh.
  return [ Class::Discover->_search_for_classes_in_file( $scanparams, \$content ) ]->map($to_record)->flatten;
}


__PACKAGE__->meta->make_immutable;
1;


__END__
=pod

=head1 NAME

Dist::Zilla::Plugin::MetaProvides::Class - Scans Dist::Zilla's .pm files and tries to identify classes using Class::Discover.

=head1 VERSION

version 1.12044910

=head1 ROLES

=head2 L<Dist::Zilla::Role::MetaProvider::Provider>

=head2 L<< C<meta_noindex>|Dist::Zilla::Role::MetaProvider::Provider/meta_noindex >>

This is a utility for people who are also using L<< C<MetaNoIndex>|Dist::Zilla::Plugin::MetaNoIndex >>,
so that its settings can be used to eliminate items from the 'provides' list.

=over 4

=item * meta_noindex = 0

By default, do nothing unusual.

=item * DEFAULT: meta_noindex = 1

When a module meets the criteria provided to L<< C<MetaNoIndex>|Dist::Zilla::Plugin::MetaNoIndex >>,
eliminate it from the metadata shipped to L<Dist::Zilla>

=back

=head1 ROLE SATISFYING METHODS

=head2 provides

A conformant function to the L<Dist::Zila::Role::MetaProvider::Provider> Role.

=head3 signature: $plugin->provides()

=head3 returns: Array of L<Dist::Zilla::MetaProvides::ProvideRecord>

=head1 PRIVATE METHODS

=head2 _classes_for

=head3 signature: $plugin->_classes_for( $filename, $file_content )

=head3 returns: Array of L<Dist::Zilla::MetaProvides::ProvideRecord>

=head1 SEE ALSO

=over 4

=item * L<Dist::Zilla::Plugin::MetaProvides>

=back

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Kent Fredric.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

