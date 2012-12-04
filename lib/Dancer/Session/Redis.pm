package Dancer::Session::Redis;
#ABSTRACT: Redis backend for Dancer 2 session storage

use Moo;
with 'Dancer::Core::Role::SessionFactory';

use JSON;
use Redis;
use Dancer::Core::Types;
use Dancer::Core::Session;

=attr redis

Accessor to the Redis client. 

=cut

has redis => (
    is      => 'rw',
    isa     => InstanceOf ['Redis'],
    lazy    => 1,
    builder => '_build_redis',
);

sub _build_redis {
    my ($self) = @_;
    Redis->new(
        server   => $self->server,
        password => $self->password,
        encoding => undef,
    );
}

=attr server

The server to connect to. Syntax is C<server:port>.

=cut

has server => (is => 'ro', required => 1);

=attr password 

The password if any.

=cut

has password => (is => 'ro');

sub _retrieve {
    my ($self, $session_id) = @_;
    my $json = $self->redis->get($session_id);
    my $hash = from_json( $json );
    return bless $hash, 'Dancer::Core::Session';
}

sub _flush {
    my ($self, $session) = @_;
    my $json = to_json( { %{ $session } } );
    $self->redis->set($session->id, $json);
}

sub _destroy {
    my ($self, $session_id) = @_;
    $self->redis->del($session_id);
}

sub _sessions {
    my ($self) = @_;
    my @keys = $self->redis->keys('*');
    return \@keys;
}

1;
__END__

=head1 DESCRIPTION

This engine provides support for session storage in Redis for Dancer 2.

This module has been written during the Perl Dancer Advent Calendar 2012 effort,
for demonstrating how to write session engine for Dancer 2.

=head1 CONFIGURATION

The only bits of configuration that are needed are the C<server:port> pair to
connect to for storing session, and the optional password.

The best way to configure the engine is in your config file:
 
    engines:
      session:
        Redis:
          server: '127.0.0.1:6379'
          password: 's3cr3t'

Now you should of course set to C<Redis> the C<session> setting:

    session: 'Redis'

Nothing more is needed. Your sessions will be stored in Redis now.

=head1 AUTHOR

This module has been written by Alexis Sukrieh C<< <sukria@gmail.com> >>.

It's released under the same terms as Perl itself.

