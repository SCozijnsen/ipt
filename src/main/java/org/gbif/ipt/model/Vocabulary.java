/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.gbif.ipt.model;

import org.gbif.metadata.eml.ipt.util.DateUtils;

import java.io.Serializable;
import java.net.MalformedURLException;
import java.net.URI;
import java.net.URL;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Objects;

import org.apache.commons.lang3.builder.CompareToBuilder;

import com.google.gson.annotations.SerializedName;
import org.jetbrains.annotations.NotNull;

/**
 * Class represents a Vocabulary.
 */
public class Vocabulary implements Comparable<Object>, Serializable {

  private static final long serialVersionUID = 22000013267L;
  @SerializedName("identifier")
  private String uriString; // identifier
  @SerializedName("url")
  private URI uriResolvable; // resolvable URI to its definition
  private String title;
  private String description;
  private String subject;
  private boolean isLatest;
  private Date issued;
  private URL link; // to further documentation
  private List<VocabularyConcept> concepts = new ArrayList<>();
  private Date modified = new Date();

  public void addConcept(VocabularyConcept concept) {
    if (concepts == null) {
      concepts = new ArrayList<>();
    }
    concept.setVocabulary(this);

    if (concept.getOrder() == -1) {
      // set the order to be the next one
      int maxOrder = 0;
      for (VocabularyConcept tc : concepts) {
        if (tc.getOrder() >= 0 && maxOrder < tc.getOrder()) {
          maxOrder = tc.getOrder();
        }
      }
      concept.setOrder(maxOrder + 1);
    }
    concepts.add(concept);
  }

  @Override
  public int compareTo(@NotNull Object object) {
    Vocabulary myClass = (Vocabulary) object;
    return new CompareToBuilder().append(this.uriString, myClass.uriString).toComparison();
  }

  @Override
  public boolean equals(Object other) {
    if (this == other) {
      return true;
    }
    if (!(other instanceof Vocabulary)) {
      return false;
    }
    Vocabulary o = (Vocabulary) other;
    return Objects.equals(uriString, o.uriString);
  }

  public VocabularyConcept findConcept(String term) {
    // try codes
    for (VocabularyConcept c : concepts) {
      if (c.getIdentifier().equalsIgnoreCase(term)) {
        return c;
      }
    }
    // try preferred
    for (VocabularyConcept c : concepts) {
      for (VocabularyTerm t : c.getPreferredTerms()) {
        if (t.getTitle().equalsIgnoreCase(term)) {
          return c;
        }
      }
    }
    // try alt
    for (VocabularyConcept c : concepts) {
      for (VocabularyTerm t : c.getAlternativeTerms()) {
        if (t.getTitle().equalsIgnoreCase(term)) {
          return c;
        }
      }
    }
    return null;
  }

  public List<VocabularyConcept> getConcepts() {
    return concepts;
  }

  public String getDescription() {
    return description;
  }

  public URL getLink() {
    return link;
  }

  public String getSubject() {
    return subject;
  }

  public String getTitle() {
    return title;
  }

  /**
   * @return date the vocabulary was last updated
   */
  public Date getModified() {
    return modified;
  }

  @Override
  public int hashCode() {
    return Objects.hashCode(uriString);
  }

  public void setConcepts(List<VocabularyConcept> concepts) {
    this.concepts = concepts;
  }

  public void setDescription(String description) {
    this.description = description;
  }

  public void setLink(String link) {
    try {
      this.link = new URL(link);
    } catch (MalformedURLException e) {
    }
  }

  public void setLink(URL link) {
    this.link = link;
  }

  public void setSubject(String subject) {
    this.subject = subject;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public void setModified(Date modified) {
    this.modified = modified;
  }

  /**
   * Identifier for Vocabulary. E.g. http://dublincore.org/documents/dcmi-type-vocabulary/
   *
   * @return identifier for Vocabulary
   */
  @SuppressWarnings("JavadocLinkAsPlainText")
  public String getUriString() {
    return uriString;
  }

  public void setUriString(String uriString) {
    this.uriString = uriString;
  }

  /**
   * Resolvable URL to Vocabulary. E.g. http://rs.gbif.org/vocabulary/dcterms/type.xml
   *
   * @return resolvable URL to Vocabulary
   */
  @SuppressWarnings("JavadocLinkAsPlainText")
  public URI getUriResolvable() {
    return uriResolvable;
  }

  public void setUriResolvable(URI uriResolvable) {
    this.uriResolvable = uriResolvable;
  }

  /**
   * @return true if this Extension is the latest version, false otherwise
   */
  public boolean isLatest() {
    return isLatest;
  }

  public void setLatest(boolean isLatest) {
    this.isLatest = isLatest;
  }

  /**
   * @return the date this Extension was issued/released/published.
   */
  public Date getIssued() {
    return issued;
  }

  public void setIssued(Date issued) {
    this.issued = issued;
  }

  /**
   * Utility to set the issued date, converting it from a textual format.
   *
   * @param dateString To set
   *
   * @throws ParseException Should it be an erroneous format
   */
  public void setIssuedDateAsString(String dateString) throws ParseException {
    issued = DateUtils.calendarDate(dateString);
  }

  @Override
  public String toString() {
    return "Vocabulary{" +
      "uriString='" + uriString + '\'' +
      ", uriResolvable=" + uriResolvable +
      ", title='" + title + '\'' +
      ", description='" + description + '\'' +
      ", subject='" + subject + '\'' +
      ", isLatest=" + isLatest +
      ", issued=" + issued +
      ", link=" + link +
      ", concepts=" + concepts +
      ", modified=" + modified +
      '}';
  }
}
