package Email::MIME::Attachment::Stripper;

use strict;
use warnings;

our $VERSION = '1.0';

use Carp;

=head1 NAME

Email::MIME::Attachment::Stripper - Strip the attachments from a mail

=head1 SYNOPSIS

	my $stripper = Email::MIME::Attachment::Stripper->new($mail);

	my Email::MIME $msg = $stripper->message;
	my @attachments       = $stripper->attachments;

=head1 DESCRIPTION

Given a Email::MIME object, detach all attachments from the
message. These are then available separately.

=head1 METHODS

=head2 new 

	my $stripper = Email::MIME::Attachment::Stripper->new($mail);

This should be instantiated with a Email::MIME object.

=head2 message

	my Email::MIME $msg = $stripper->message;

This returns the message with all the attachments detached. This will
alter both the body and the header of the message.

=head2 attachments

	my @attachments = $stripper->attachments;

This returns a list of all the attachments we found in the message,
as a hash of { filename, content_type, payload }.

=head1 CREDITS AND LICENSE

This module is incredibly closely derived from Tony Bowden's
L<Mail::Message::Attachment::Stripper>; this derivation was done by
Simon Cozens (C<simon@cpan.org>), and you receive this under the same
terms as Tony's original module.

=cut

sub new {
	my ($class, $msg) = @_;
	croak "Need a message" unless eval { $msg->isa("Email::MIME") };
	bless { _msg => $msg }, $class;
}

sub message {
	my $self = shift;
	$self->_detach_all unless exists $self->{_atts};
	return $self->{_msg};
}

sub attachments {
	my $self = shift;
	$self->_detach_all unless exists $self->{_atts};
	return $self->{_atts} ? @{ $self->{_atts} } : ();
}

sub _detach_all {
	my $self = shift;
	my $mm   = $self->{_msg};

	$self->{_atts} = [];
	$self->{_body} = [];

	$self->_handle_part($mm);
	$mm->Email::Simple::body($self->{_body});
    $mm->fill_parts;
	$self;
}

sub _handle_part {
	my ($self, $mm) = @_;
	foreach my $part ($mm->parts) {
		if ($self->_is_inline_text($part)) {
			$self->_gather_body($part);
		} elsif ($self->_should_recurse($part)) {
			$self->_handle_part($part);
		} else {
			$self->_gather_att($part);
		}
	}
}

sub _gather_body {    # Gen 25:8
	my ($self, $part) = @_;
	push @{ $self->{_body} }, $part->body;
}

sub _gather_att {
	my ($self, $part) = @_;

	push @{ $self->{_atts} },
		{
		content_type => $part->{ct}{discrete}."/".$part->{ct}{composite},
		payload      => $part->body,
		filename     => $self->_filename_for($part),
		};
}

sub _should_recurse {
	my ($self, $part) = @_;
	return 0 if lc($part->header("Content-Type") =~ m{message/rfc822});
	return 1 if $part->parts > 1;
	return 0;
}

sub _is_inline_text {
	my ($self, $part) = @_;
	if ($part->header("Content-Type") =~ m{text/plain}i) {
		my $disp = $part->header("Content-Disposition");
		return 1 if $disp && $disp =~ /inline/;
		return 0 if $self->_filename_for($part);
		return 1;
	}
	return 0;
}

sub _filename_for {
	my ($self, $part) = @_;
    my $fn;
    return $fn if $fn = $part->{ct}{attributes}{"filename"};
    if (my $cd = $part->header("Content-Disposition")) {
        my $parsed = Email::MIME::ContentType::parse_content_type("foo/$cd");
        return $fn if $fn = $parsed->{attributes}{filename};
    }
    return "";
}

1;
