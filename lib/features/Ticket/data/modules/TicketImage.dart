
import 'dart:io';

class TicketImage {
 final File? localSource;
 final String? urlSource;

  TicketImage.local(File file) : localSource = file , urlSource = null;
  TicketImage.remote(String url) : urlSource = url , localSource = null;

  bool isLocal () => localSource != null;

}