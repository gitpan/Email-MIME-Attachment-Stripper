
use strict;
use warnings;

use Test::More tests =>28;

use_ok "Email::MIME::Attachment::Stripper";
use Email::MIME;

open IN, "t/Mail/attached1" or die "Can't read mail";
my $message = do { local $/; <IN>; };

{
	my $msg = Email::MIME->new($message);
	isa_ok $msg => "Email::MIME";
	ok $msg->parts > 1, "Message has attachments";

	ok my $strp = Email::MIME::Attachment::Stripper->new($msg), "Get stripper";
	isa_ok $strp => "Email::MIME::Attachment::Stripper";

	ok my $detached = $strp->message, "Get detached message";
	isa_ok $detached => "Email::MIME";
	ok !($detached->parts > 1), "Message no longer has attachments";

	ok my @att = $strp->attachments, "Get attachments";
	is @att, 3, "Got 3 attachments";

	is $att[0]->{content_type}, "text/plain", "First attachment is plain";
	is $att[1]->{content_type}, "application/postscript", "2nd is .ps";
	is $att[2]->{content_type}, "text/html", "3rd is html";

	is $att[0]->{filename}, "wzl.dot", "First attachment named OK";
	is $att[1]->{filename}, "wzl.ps", "As is 2nd";
	is $att[2]->{filename}, "zeldo.html", "And 3rd";

	like $att[0]->{payload}, qr/^digraph G/, "First attachment has contains the right stuff";
	like $att[1]->{payload}, qr/^%!PS-Adobe-2\.0/, "...As does second";
}


open IN, "t/Mail/attached2" or die "Can't read mail";
$message = do { local $/; <IN>; };
{
	my $msg = Email::MIME->new($message);
	isa_ok $msg => "Email::MIME";
	ok $msg->parts >1, "Message has attachments";

	ok my $strp = Email::MIME::Attachment::Stripper->new($msg), "Get stripper";
	isa_ok $strp => "Email::MIME::Attachment::Stripper";

	ok my $detached = $strp->message, "Get detached message";
	isa_ok $detached => "Email::MIME";
	ok !($detached->parts > 1), "Message no longer has attachments";

	is $strp->attachments, 1, "Got 1 attachment";
	my ($att) = $strp->attachments;
	is $att->{content_type}, "message/rfc822", "attachment is another message";
	is $att->{filename}, "", "With no name";
}


