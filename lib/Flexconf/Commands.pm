package Flexconf::Commands;

use Flexconf;

sub new {
  my ($package, $flexconf) = @_;
  bless {conf=>$flexconf}, $package;
}


*get = \&redirect;
*put = \&redirect;
*load = \&redirect;
*save = \&redirect;
sub redirect {
  my ($self, $cmd, @args) = @_;
  $self->{conf}->$cmd(@args);
}

*copy = \&two_args;
*move = \&two_args;
sub two_args {
  my ($self, $cmd, $to, $from) = @_;
  $self->{conf}->$cmd($to, $from);
}

*cp = \&rev_two_args;
*mv = \&rev_two_args;
sub rev_two_args {
  my ($self, $cmd, $from, $to) = @_;
  $self->{conf}->$cmd($to, $from);
}

*rm = \&remove;
sub remove {
  my ($self, $cmd, $path) = @_;
  $self->{conf}->$cmd($path);
}

sub tree {
  my ($self, $prefix_cmd, $prefix_arg, $cmd, @args) = @_;
  my $fn = $prefix_cmd . '_' . $cmd;
  my $root = $self->{conf};
  my $tree = Flexconf->new($root->get($prefix_arg));
  $self->{conf} = $tree;
  eval {
    $self->$cmd($cmd, @args);
  };
  my $exception = $@;
  $root->assign($prefix_arg, $tree->data);
  $self->{conf} = $root;
  die $exception if $exception;
}

1;
