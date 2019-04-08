
void parseMetadata(String[] dataInput) {

  // skip the header
  for(int i=1; i<dataInput.length; i++) {
        
    // parse each line from the CSV file
    String[] data = splitTokens(dataInput[i], ",;");

    int id = parseInt(data[0]);
    filenames[id] = data[1];
    
    // skip the first two elements (ID and filename)
    for(int h=2; h<data.length; h++) {
      
      data[h] = trim(data[h]);      
      if(!data[h].equals("")) { // ignore empty tags

        // make all tags lowercase only
        data[h] = data[h].toLowerCase();
        
        // for each element in the line, check to see if it is already in the tags array
        boolean newTag = true;      
        for(int j=0; j<tags.length; j++) {
          if(tags[j].equals(data[h])) {
            newTag = false;
            break;
          }
        }
        // if it isn't, append it.   
        if(newTag) {
          tags = append(tags, data[h]);
        }
      }
    }
  }
  
  // sort the tags array
  tags = sort(tags);

  // initialise the tag associations list with empty arrays
  for(int i=0; i<tags.length; i++) { 
    int[] list = new int[0];
    associations.add(list);
  }

  // loop through the data table again, this time to populate the associations arrays 
  for(int i=1; i<dataInput.length; i++) {
        
    String[] data = splitTokens(dataInput[i], ",;");
    int id = parseInt(data[0]);
    
    for(int h=2; h<data.length; h++) {     
      data[h] = trim(data[h]);
      data[h] = data[h].toLowerCase();   
    }

    // look through the whole tag array each time
    for(int j=0; j<tags.length; j++) {
      // comparing to each tag for the entry
      for(int h=2; h<data.length; h++) { 
        // if it matches, get the list for that tag and append the entry id
        if(data[h].equals(tags[j])) {
          int[] list = associations.get(j);
          list = append(list, id);
          associations.set(j, list);
        }
      }
    }
  }
  
}


// looks for tags with accented characters (à  á  â  ã  ä  å    ç    è  é  ê  ë    ì  í  î  ï    ò  ó  ô  õ  ö    ù  ú  û  ü)
// and replaces them with the unaccented versions
void makeUnaccentedTags() {  

  unaccentedIndex = tags.length + 1;
  
  for(int i=0; i<tags.length; i++) {
    
    char tag[] = tags[i].toCharArray();
    boolean accented = false;
    
    for(int h=0; h<tags[i].length(); h++) {
      if(tag[h] >= 224 && tag[h] <= 229) { tag[h] = 'a'; accented = true; }
      if(tag[h] >= 232 && tag[h] <= 235) { tag[h] = 'e'; accented = true; }
      if(tag[h] >= 236 && tag[h] <= 239) { tag[h] = 'i'; accented = true; }
      if(tag[h] >= 242 && tag[h] <= 246) { tag[h] = 'o'; accented = true; }
      if(tag[h] >= 249 && tag[h] <= 252) { tag[h] = 'u'; accented = true; }
      if(tag[h] == 231) { tag[h] = 'c'; accented = true; }
    }
    
    if(accented) {

      String a = new String(tag);
      // get the id list for the accented tag
      int[] list1 = associations.get(i);

      int[] list2 = new int[0];
      int j;

      // check if an unaccented version of the tag is already in the database
      boolean tagExists = false;
      for(j=0; j<tags.length; j++) {
        if(a.equals(tags[j])) { 
          // if it does, get the id list for that tag
          list2 = associations.get(j);
          tagExists = true;
          break;
        }
      }
      if(tagExists) {
        // and add the ids to those for the accented tag and vice versa
        list1 = concat(list1, list2);
        associations.set(i, list1);
        associations.set(j, list1);
      } else {
        // otherwise add it as a new tag
        tags = append(tags, a);
        associations.add(list1);
      }
    }
    
  }
  
}


void getIDs(String tag, boolean cleanSearch) {

  // find tag index
  int tagIndex;
  
  for (tagIndex=0; tagIndex<tags.length; tagIndex++) {
    if (tag.equals(tags[tagIndex])) {
      break;
    }
  }

  // if a tag was found
  if (tagIndex < tags.length) {
    
    println("tagIndex = " + tagIndex);

    // get an array of ID's for selected tag  
    int[] tagResults = associations.get(tagIndex);

    if(cleanSearch) {
      // if a fresh new search, clear the intlist, and fill with tagResults IDs
      imageIDs.clear();
      for(int i=0; i<tagResults.length; i++) {
        imageIDs.append(tagResults[i]);
      }

    } else {
      // otherwise it is a refined search, in which case remove all ids that are not in tagResults array

      IntList filteredIDs = new IntList();  

      for(int i=0; i<tagResults.length; i++) {
        if(imageIDs.hasValue(tagResults[i])) {
          filteredIDs.append(tagResults[i]);
        }
      }

      imageIDs = filteredIDs;
    }

    imageIDs.shuffle(); // randomise image order.
    numPages = ceil( (float)imageIDs.size() / (rows*columns) );
    page = 1;
    println("found " + imageIDs.size() + " images, for " + numPages + " pages" + '\n');

  } else {
    // otherwise if no tag was found
    //numResults = 0;
    imageIDs.clear();
    numPages = 0;
    println("tag not found" + '\n');
  }
  
}


int[] getTags(int id) {

  int[] tagList = new int[0];

  for(int j=0; j<tags.length; j++) {
    int[] list = associations.get(j);

    for(int i=0; i<list.length; i++) {
      if(list[i] == id) {
        tagList = append(tagList, j);
        break;
      }
    }
  }

  return(tagList);  
}


void exportTags() {
  String[] export = subset(tags, 0, unaccentedIndex - 1);
  saveStrings("../tags.txt", export);
  println("exported tag list to ../tags.txt");
}