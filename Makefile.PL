use ExtUtils::MakeMaker;

use strict;
use warnings;

my $PACKAGE = "Email::MIME::Attachment::Stripper";
my $LOCN    = "lib/Email/MIME/Attachment/Stripper.pm";

WriteMakefile(
	AUTHOR        => 'Simon Cozens <simon@cpan.org>',
	NAME          => $PACKAGE,
	ABSTRACT_FROM => $LOCN,
	VERSION_FROM  => $LOCN,
	PREREQ_PM     => {
		'Test::More' => 0.45,
		'Email::MIME' => 1.3,
        'Email::MIME::Encodings' => 1.1
	},
	dist => {
		COMPRESS     => 'gzip -9',
		SUFFIX       => '.gz',
		DIST_DEFAULT => 'all tardist',
	},

);
