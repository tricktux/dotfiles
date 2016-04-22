#$pdf_update_method = 0;
#$pdf_previewer = 'start okular';
$pdf_previewer = "start xpdf -remote %R %O %S";
$pdf_update_method = 4;
$pdf_update_command = "xpdf -remote %R -reload";
