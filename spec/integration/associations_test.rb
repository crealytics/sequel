require File.join(File.dirname(File.expand_path(__FILE__)), 'spec_helper.rb')

shared_examples_for "regular and composite key associations" do  
  specify "should return no objects if none are associated" do
    @album.artist.should == nil
    @artist.first_album.should == nil
    @artist.albums.should == []
    @album.tags.should == []
    @tag.albums.should == []
  end

  specify "should have add and set methods work any associated objects" do
    @album.update(:artist => @artist)
    @album.add_tag(@tag)
    
    @album.reload
    @artist.reload
    @tag.reload
    
    @album.artist.should == @artist
    @artist.first_album.should == @album
    @artist.albums.should == [@album]
    @album.tags.should == [@tag]
    @tag.albums.should == [@album]
  end
  
  specify "should work correctly with prepared_statements_association plugin" do
    @album.update(:artist => @artist)
    @album.add_tag(@tag)
    
    @album.reload
    @artist.reload
    @tag.reload
    
    [Tag, Album, Artist].each{|x| x.plugin :prepared_statements_associations}
    @album.artist.should == @artist
    @artist.first_album.should == @album
    @artist.albums.should == [@album]
    @album.tags.should == [@tag]
    @tag.albums.should == [@album]
  end

  specify "should work correctly when filtering by associations" do
    @album.update(:artist => @artist)
    @album.add_tag(@tag)
    
    Artist.filter(:albums=>@album).all.should == [@artist]
    Artist.filter(:first_album=>@album).all.should == [@artist]
    Album.filter(:artist=>@artist).all.should == [@album]
    Album.filter(:tags=>@tag).all.should == [@album]
    Tag.filter(:albums=>@album).all.should == [@tag]
    Album.filter(:artist=>@artist, :tags=>@tag).all.should == [@album]
    @artist.albums_dataset.filter(:tags=>@tag).all.should == [@album]
  end

  specify "should work correctly when excluding by associations" do
    @album.update(:artist => @artist)
    @album.add_tag(@tag)
    album, artist, tag = @pr.call

    Artist.exclude(:albums=>@album).all.should == [artist]
    Artist.exclude(:first_album=>@album).all.should == [artist]
    Album.exclude(:artist=>@artist).all.should == [album]
    Album.exclude(:tags=>@tag).all.should == [album]
    Tag.exclude(:albums=>@album).all.should == [tag]
    Album.exclude(:artist=>@artist, :tags=>@tag).all.should == [album]
  end
  
  specify "should work correctly when filtering by multiple associations" do
    album, artist, tag = @pr.call
    @album.update(:artist => @artist)
    @album.add_tag(@tag)
    
    Artist.filter(:albums=>[@album, album]).all.should == [@artist]
    Artist.filter(:first_album=>[@album, album]).all.should == [@artist]
    Album.filter(:artist=>[@artist, artist]).all.should == [@album]
    Album.filter(:tags=>[@tag, tag]).all.should == [@album]
    Tag.filter(:albums=>[@album, album]).all.should == [@tag]
    Album.filter(:artist=>[@artist, artist], :tags=>[@tag, tag]).all.should == [@album]
    @artist.albums_dataset.filter(:tags=>[@tag, tag]).all.should == [@album]

    album.add_tag(tag)

    Artist.filter(:albums=>[@album, album]).all.should == [@artist]
    Artist.filter(:first_album=>[@album, album]).all.should == [@artist]
    Album.filter(:artist=>[@artist, artist]).all.should == [@album]
    Album.filter(:tags=>[@tag, tag]).all.sort_by{|x| x.pk}.should == [@album, album]
    Tag.filter(:albums=>[@album, album]).all.sort_by{|x| x.pk}.should == [@tag, tag]
    Album.filter(:artist=>[@artist, artist], :tags=>[@tag, tag]).all.should == [@album]

    album.update(:artist => artist)

    Artist.filter(:albums=>[@album, album]).all.sort_by{|x| x.pk}.should == [@artist, artist]
    Artist.filter(:first_album=>[@album, album]).all.sort_by{|x| x.pk}.should == [@artist, artist]
    Album.filter(:artist=>[@artist, artist]).all.sort_by{|x| x.pk}.should == [@album, album]
    Album.filter(:tags=>[@tag, tag]).all.sort_by{|x| x.pk}.should == [@album, album]
    Tag.filter(:albums=>[@album, album]).all.sort_by{|x| x.pk}.should == [@tag, tag]
    Album.filter(:artist=>[@artist, artist], :tags=>[@tag, tag]).all.sort_by{|x| x.pk}.should == [@album, album]
  end

  specify "should work correctly when excluding by multiple associations" do
    album, artist, tag = @pr.call

    Artist.exclude(:albums=>[@album, album]).all.sort_by{|x| x.pk}.should == [@artist, artist]
    Artist.exclude(:first_album=>[@album, album]).all.sort_by{|x| x.pk}.should == [@artist, artist]
    Album.exclude(:artist=>[@artist, artist]).all.sort_by{|x| x.pk}.should == [@album, album]
    Album.exclude(:tags=>[@tag, tag]).all.sort_by{|x| x.pk}.should == [@album, album]
    Tag.exclude(:albums=>[@album, album]).all.sort_by{|x| x.pk}.should == [@tag, tag]
    Album.exclude(:artist=>[@artist, artist], :tags=>[@tag, tag]).all.sort_by{|x| x.pk}.should == [@album, album]

    @album.update(:artist => @artist)
    @album.add_tag(@tag)

    Artist.exclude(:albums=>[@album, album]).all.sort_by{|x| x.pk}.should == [artist]
    Artist.exclude(:first_album=>[@album, album]).all.sort_by{|x| x.pk}.should == [artist]
    Album.exclude(:artist=>[@artist, artist]).all.sort_by{|x| x.pk}.should == [album]
    Album.exclude(:tags=>[@tag, tag]).all.sort_by{|x| x.pk}.should == [album]
    Tag.exclude(:albums=>[@album, album]).all.sort_by{|x| x.pk}.should == [tag]
    Album.exclude(:artist=>[@artist, artist], :tags=>[@tag, tag]).all.sort_by{|x| x.pk}.should == [album]

    album.add_tag(tag)

    Artist.exclude(:albums=>[@album, album]).all.should == [artist]
    Artist.exclude(:first_album=>[@album, album]).all.should == [artist]
    Album.exclude(:artist=>[@artist, artist]).all.should == [album]
    Album.exclude(:tags=>[@tag, tag]).all.should == []
    Tag.exclude(:albums=>[@album, album]).all.should == []
    Album.exclude(:artist=>[@artist, artist], :tags=>[@tag, tag]).all.should == [album]

    album.update(:artist => artist)

    Artist.exclude(:albums=>[@album, album]).all.should == []
    Artist.exclude(:first_album=>[@album, album]).all.should == []
    Album.exclude(:artist=>[@artist, artist]).all.should == []
    Album.exclude(:tags=>[@tag, tag]).all.should == []
    Tag.exclude(:albums=>[@album, album]).all.should == []
    Album.exclude(:artist=>[@artist, artist], :tags=>[@tag, tag]).all.should == []
  end
  
  specify "should work correctly when excluding by associations in regards to NULL values" do
    Artist.exclude(:albums=>@album).all.should == [@artist]
    Artist.exclude(:first_album=>@album).all.should == [@artist]
    Album.exclude(:artist=>@artist).all.should == [@album]
    Album.exclude(:tags=>@tag).all.should == [@album]
    Tag.exclude(:albums=>@album).all.should == [@tag]
    Album.exclude(:artist=>@artist, :tags=>@tag).all.should == [@album]

    @album.update(:artist => @artist)
    @artist.albums_dataset.exclude(:tags=>@tag).all.should == [@album]
  end

  specify "should handle NULL values in join table correctly when filtering/excluding many_to_many associations" do
    @ins.call
    Album.exclude(:tags=>@tag).all.should == [@album]
    @album.add_tag(@tag)
    Album.filter(:tags=>@tag).all.should == [@album]
    album, artist, tag = @pr.call
    Album.exclude(:tags=>@tag).all.should == [album]
    Album.exclude(:tags=>tag).all.sort_by{|x| x.pk}.should == [@album, album]
  end

  specify "should work correctly when filtering by association datasets" do
    album, artist, tag = @pr.call
    @album.update(:artist => @artist)
    @album.add_tag(@tag)
    album.add_tag(tag)
    album.update(:artist => artist)

    Artist.filter(:albums=>Album.dataset).all.sort_by{|x| x.pk}.should == [@artist, artist]
    Artist.filter(:albums=>Album.dataset.filter(Array(Album.primary_key).zip(Array(album.pk)))).all.sort_by{|x| x.pk}.should == [artist]
    Artist.filter(:albums=>Album.dataset.filter(1=>0)).all.sort_by{|x| x.pk}.should == []
    Artist.filter(:first_album=>Album.dataset).all.sort_by{|x| x.pk}.should == [@artist, artist]
    Artist.filter(:first_album=>Album.dataset.filter(Array(Album.primary_key).zip(Array(album.pk)))).all.sort_by{|x| x.pk}.should == [artist]
    Artist.filter(:first_album=>Album.dataset.filter(1=>0)).all.sort_by{|x| x.pk}.should == []
    Album.filter(:artist=>Artist.dataset).all.sort_by{|x| x.pk}.should == [@album, album]
    Album.filter(:artist=>Artist.dataset.filter(Array(Artist.primary_key).zip(Array(artist.pk)))).all.sort_by{|x| x.pk}.should == [album]
    Album.filter(:artist=>Artist.dataset.filter(1=>0)).all.sort_by{|x| x.pk}.should == []
    Album.filter(:tags=>Tag.dataset).all.sort_by{|x| x.pk}.should == [@album, album]
    Album.filter(:tags=>Tag.dataset.filter(Array(Tag.primary_key).zip(Array(tag.pk)))).all.sort_by{|x| x.pk}.should == [album]
    Album.filter(:tags=>Tag.dataset.filter(1=>0)).all.sort_by{|x| x.pk}.should == []
    Tag.filter(:albums=>Album.dataset).all.sort_by{|x| x.pk}.should == [@tag, tag]
    Tag.filter(:albums=>Album.dataset.filter(Array(Album.primary_key).zip(Array(album.pk)))).all.sort_by{|x| x.pk}.should == [tag]
    Tag.filter(:albums=>Album.dataset.filter(1=>0)).all.sort_by{|x| x.pk}.should == []
  end

  specify "should work correctly when excluding by association datasets" do
    album, artist, tag = @pr.call
    @album.update(:artist => @artist)
    @album.add_tag(@tag)
    album.add_tag(tag)
    album.update(:artist => artist)

    Artist.exclude(:albums=>Album.dataset).all.sort_by{|x| x.pk}.should == []
    Artist.exclude(:albums=>Album.dataset.filter(Array(Album.primary_key).zip(Array(album.pk)))).all.sort_by{|x| x.pk}.should == [@artist]
    Artist.exclude(:albums=>Album.dataset.filter(1=>0)).all.sort_by{|x| x.pk}.should == [@artist, artist]
    Album.exclude(:artist=>Artist.dataset).all.sort_by{|x| x.pk}.should == []
    Album.exclude(:artist=>Artist.dataset.filter(Array(Artist.primary_key).zip(Array(artist.pk)))).all.sort_by{|x| x.pk}.should == [@album]
    Album.exclude(:artist=>Artist.dataset.filter(1=>0)).all.sort_by{|x| x.pk}.should == [@album, album]
    Album.exclude(:tags=>Tag.dataset).all.sort_by{|x| x.pk}.should == []
    Album.exclude(:tags=>Tag.dataset.filter(Array(Tag.primary_key).zip(Array(tag.pk)))).all.sort_by{|x| x.pk}.should == [@album]
    Album.exclude(:tags=>Tag.dataset.filter(1=>0)).all.sort_by{|x| x.pk}.should == [@album, album]
    Tag.exclude(:albums=>Album.dataset).all.sort_by{|x| x.pk}.should == []
    Tag.exclude(:albums=>Album.dataset.filter(Array(Album.primary_key).zip(Array(album.pk)))).all.sort_by{|x| x.pk}.should == [@tag]
    Tag.exclude(:albums=>Album.dataset.filter(1=>0)).all.sort_by{|x| x.pk}.should == [@tag, tag]
  end

  specify "should have remove methods work" do
    @album.update(:artist => @artist)
    @album.add_tag(@tag)
    
    @album.update(:artist => nil)
    @album.remove_tag(@tag)
    
    @album.reload
    @artist.reload
    @tag.reload
    
    @album.artist.should == nil
    @artist.albums.should == []
    @album.tags.should == []
    @tag.albums.should == []
  end
  
  specify "should have remove_all methods work" do
    @artist.add_album(@album)
    @album.add_tag(@tag)
    
    @artist.remove_all_albums
    @album.remove_all_tags
    
    @album.reload
    @artist.reload
    @tag.reload
    
    @album.artist.should == nil
    @artist.albums.should == []
    @album.tags.should == []
    @tag.albums.should == []
  end
  
  specify "should eager load via eager correctly" do
    @album.update(:artist => @artist)
    @album.add_tag(@tag)
    
    a = Artist.eager(:albums=>:tags).eager(:first_album).all
    a.should == [@artist]
    a.first.albums.should == [@album]
    a.first.first_album.should == @album
    a.first.albums.first.tags.should == [@tag]
    
    a = Tag.eager(:albums=>:artist).all
    a.should == [@tag]
    a.first.albums.should == [@album]
    a.first.albums.first.artist.should == @artist
  end
  
  specify "should eager load one_to_one associations with multiple matching objects correctly" do
    @album.update(:artist => @artist)
    diff_album = @diff_album.call
    
    a = Artist.eager(:first_album).all
    a.should == [@artist]
    a.first.first_album.should == @album

    same_album = @same_album.call
    a = Artist.eager(:first_album).all
    a.should == [@artist]
    [@album, same_album].should include(a.first.first_album)
  end
  
  specify "should eager load via eager_graph correctly" do
    @album.update(:artist => @artist)
    @album.add_tag(@tag)
    
    a = Artist.eager_graph(:albums=>:tags).eager_graph(:first_album).all
    a.should == [@artist]
    a.first.albums.should == [@album]
    a.first.first_album.should == @album
    a.first.albums.first.tags.should == [@tag]
    
    a = Tag.eager_graph(:albums=>:artist).all
    a.should == [@tag]
    a.first.albums.should == [@album]
    a.first.albums.first.artist.should == @artist
  end
  
  specify "should work with a many_through_many association" do
    @album.update(:artist => @artist)
    @album.add_tag(@tag)

    @album.reload
    @artist.reload
    @tag.reload
    
    @album.tags.should == [@tag]
    
    a = Artist.eager(:tags).all
    a.should == [@artist]
    a.first.tags.should == [@tag]
    
    a = Artist.eager_graph(:tags).all
    a.should == [@artist]
    a.first.tags.should == [@tag]
    
    a = Album.eager(:artist=>:tags).all
    a.should == [@album]
    a.first.artist.should == @artist
    a.first.artist.tags.should == [@tag]
    
    a = Album.eager_graph(:artist=>:tags).all
    a.should == [@album]
    a.first.artist.should == @artist
    a.first.artist.tags.should == [@tag]
  end
end

describe "Sequel::Model Simple Associations" do
  before do
    @db = INTEGRATION_DB
    @db.create_table!(:artists) do
      primary_key :id
      String :name
    end
    @db.create_table!(:albums) do
      primary_key :id
      String :name
      foreign_key :artist_id, :artists
    end
    @db.create_table!(:tags) do
      primary_key :id
      String :name
    end
    @db.create_table!(:albums_tags) do
      foreign_key :album_id, :albums
      foreign_key :tag_id, :tags
    end
    class ::Artist < Sequel::Model(@db)
      one_to_many :albums
      one_to_one :first_album, :class=>:Album, :order=>:name
      plugin :many_through_many
      many_through_many :tags, [[:albums, :artist_id, :id], [:albums_tags, :album_id, :tag_id]]
    end
    class ::Album < Sequel::Model(@db)
      many_to_one :artist
      many_to_many :tags
    end
    class ::Tag < Sequel::Model(@db)
      many_to_many :albums
    end
    @album = Album.create(:name=>'Al')
    @artist = Artist.create(:name=>'Ar')
    @tag = Tag.create(:name=>'T')
    @same_album = lambda{Album.create(:name=>'Al', :artist_id=>@artist.id)}
    @diff_album = lambda{Album.create(:name=>'lA', :artist_id=>@artist.id)}
    @pr = lambda{[Album.create(:name=>'Al2'),Artist.create(:name=>'Ar2'),Tag.create(:name=>'T2')]}
    @ins = lambda{@db[:albums_tags].insert(:tag_id=>@tag.id)}
  end
  after do
    @db.drop_table(:albums_tags, :tags, :albums, :artists)
    [:Tag, :Album, :Artist].each{|x| Object.send(:remove_const, x)}
  end
  
  it_should_behave_like "regular and composite key associations"

  specify "should handle aliased tables when eager_graphing" do
    @album.update(:artist => @artist)
    @album.add_tag(@tag)
    
    Artist.set_dataset(:artists___ar)
    Album.set_dataset(:albums___a)
    Tag.set_dataset(:tags___t)
    Artist.one_to_many :balbums, :class=>Album, :key=>:artist_id
    Album.many_to_many :btags, :class=>Tag, :join_table=>:albums_tags, :right_key=>:tag_id
    Album.many_to_one :bartist, :class=>Artist, :key=>:artist_id
    Tag.many_to_many :balbums, :class=>Album, :join_table=>:albums_tags, :right_key=>:album_id

    a = Artist.eager_graph(:balbums=>:btags).all
    a.should == [@artist]
    a.first.balbums.should == [@album]
    a.first.balbums.first.btags.should == [@tag]
    
    a = Tag.eager_graph(:balbums=>:bartist).all
    a.should == [@tag]
    a.first.balbums.should == [@album]
    a.first.balbums.first.bartist.should == @artist
  end
  
  specify "should have add method accept hashes and create new records" do
    @artist.remove_all_albums
    Album.delete
    @album = @artist.add_album(:name=>'Al2')
    Album.first[:name].should == 'Al2'
    @artist.albums_dataset.first[:name].should == 'Al2'
    
    @album.remove_all_tags
    Tag.delete
    @album.add_tag(:name=>'T2')
    Tag.first[:name].should == 'T2'
    @album.tags_dataset.first[:name].should == 'T2'
  end
  
  specify "should have add method accept primary key and add related records" do
    @artist.remove_all_albums
    @artist.add_album(@album.id)
    @artist.albums_dataset.first[:id].should == @album.id

    @album.remove_all_tags
    @album.add_tag(@tag.id)
    @album.tags_dataset.first[:id].should == @tag.id
  end
  
  specify "should have remove method accept primary key and remove related album" do
    @artist.add_album(@album)
    @artist.reload.remove_album(@album.id)
    @artist.reload.albums.should == []
    
    @album.add_tag(@tag)
    @album.reload.remove_tag(@tag.id)
    @tag.reload.albums.should == []
  end
  
  specify "should handle dynamic callbacks for regular loading" do
    @artist.add_album(@album)

    @artist.albums.should == [@album]
    @artist.albums(proc{|ds| ds.exclude(:id=>@album.id)}).should == []
    @artist.albums(proc{|ds| ds.filter(:id=>@album.id)}).should == [@album]

    @album.artist.should == @artist
    @album.artist(proc{|ds| ds.exclude(:id=>@artist.id)}).should == nil
    @album.artist(proc{|ds| ds.filter(:id=>@artist.id)}).should == @artist

    if RUBY_VERSION >= '1.8.7'
      @artist.albums{|ds| ds.exclude(:id=>@album.id)}.should == []
      @artist.albums{|ds| ds.filter(:id=>@album.id)}.should == [@album]
      @album.artist{|ds| ds.exclude(:id=>@artist.id)}.should == nil
      @album.artist{|ds| ds.filter(:id=>@artist.id)}.should == @artist
    end
  end
  
  specify "should handle dynamic callbacks for eager loading via eager and eager_graph" do
    @artist.add_album(@album)
    @album.add_tag(@tag)
    album2 = @artist.add_album(:name=>'Foo')
    tag2 = album2.add_tag(:name=>'T2')

    artist = Artist.eager(:albums=>:tags).all.first
    artist.albums.should == [@album, album2]
    artist.albums.map{|x| x.tags}.should == [[@tag], [tag2]]

    artist = Artist.eager_graph(:albums=>:tags).all.first
    artist.albums.should == [@album, album2]
    artist.albums.map{|x| x.tags}.should == [[@tag], [tag2]]

    artist = Artist.eager(:albums=>{proc{|ds| ds.where(:id=>album2.id)}=>:tags}).all.first
    artist.albums.should == [album2]
    artist.albums.first.tags.should == [tag2]

    artist = Artist.eager_graph(:albums=>{proc{|ds| ds.where(:id=>album2.id)}=>:tags}).all.first
    artist.albums.should == [album2]
    artist.albums.first.tags.should == [tag2]
  end
  
  specify "should have remove method raise an error for one_to_many records if the object isn't already associated" do
    proc{@artist.remove_album(@album.id)}.should raise_error(Sequel::Error)
    proc{@artist.remove_album(@album)}.should raise_error(Sequel::Error)
  end
end

describe "Sequel::Model Composite Key Associations" do
  before do
    @db = INTEGRATION_DB
    @db.create_table!(:artists) do
      Integer :id1
      Integer :id2
      String :name
      primary_key [:id1, :id2]
    end
    @db.create_table!(:albums) do
      Integer :id1
      Integer :id2
      String :name
      Integer :artist_id1
      Integer :artist_id2
      foreign_key [:artist_id1, :artist_id2], :artists
      primary_key [:id1, :id2]
    end
    @db.create_table!(:tags) do
      Integer :id1
      Integer :id2
      String :name
      primary_key [:id1, :id2]
    end
    @db.create_table!(:albums_tags) do
      Integer :album_id1
      Integer :album_id2
      Integer :tag_id1
      Integer :tag_id2
      foreign_key [:album_id1, :album_id2], :albums
      foreign_key [:tag_id1, :tag_id2], :tags
    end
    class ::Artist < Sequel::Model(@db)
      set_primary_key :id1, :id2
      unrestrict_primary_key
      one_to_many :albums, :key=>[:artist_id1, :artist_id2]
      one_to_one :first_album, :key=>[:artist_id1, :artist_id2], :class=>:Album, :order=>:name
      plugin :many_through_many
      many_through_many :tags, [[:albums, [:artist_id1, :artist_id2], [:id1, :id2]], [:albums_tags, [:album_id1, :album_id2], [:tag_id1, :tag_id2]]]
    end
    class ::Album < Sequel::Model(@db)
      set_primary_key :id1, :id2
      unrestrict_primary_key
      many_to_one :artist, :key=>[:artist_id1, :artist_id2]
      many_to_many :tags, :left_key=>[:album_id1, :album_id2], :right_key=>[:tag_id1, :tag_id2]
    end
    class ::Tag < Sequel::Model(@db)
      set_primary_key :id1, :id2
      unrestrict_primary_key
      many_to_many :albums, :right_key=>[:album_id1, :album_id2], :left_key=>[:tag_id1, :tag_id2]
    end
    @album = Album.create(:name=>'Al', :id1=>1, :id2=>2)
    @artist = Artist.create(:name=>'Ar', :id1=>3, :id2=>4)
    @tag = Tag.create(:name=>'T', :id1=>5, :id2=>6)
    @same_album = lambda{Album.create(:name=>'Al', :id1=>7, :id2=>8, :artist_id1=>3, :artist_id2=>4)}
    @diff_album = lambda{Album.create(:name=>'lA', :id1=>9, :id2=>10, :artist_id1=>3, :artist_id2=>4)}
    @pr = lambda{[Album.create(:name=>'Al2', :id1=>11, :id2=>12),Artist.create(:name=>'Ar2', :id1=>13, :id2=>14),Tag.create(:name=>'T2', :id1=>15, :id2=>16)]}
    @ins = lambda{@db[:albums_tags].insert(:tag_id1=>@tag.id1, :tag_id2=>@tag.id2)}
  end
  after do
    @db.drop_table(:albums_tags, :tags, :albums, :artists)
    [:Tag, :Album, :Artist].each{|x| Object.send(:remove_const, x)}
  end

  it_should_behave_like "regular and composite key associations"

  specify "should have add method accept hashes and create new records" do
    @artist.remove_all_albums
    Album.delete
    @artist.add_album(:id1=>1, :id2=>2, :name=>'Al2')
    Album.first[:name].should == 'Al2'
    @artist.albums_dataset.first[:name].should == 'Al2'
    
    @album.remove_all_tags
    Tag.delete
    @album.add_tag(:id1=>1, :id2=>2, :name=>'T2')
    Tag.first[:name].should == 'T2'
    @album.tags_dataset.first[:name].should == 'T2'
  end
  
  specify "should have add method accept primary key and add related records" do
    @artist.remove_all_albums
    @artist.add_album([@album.id1, @album.id2])
    @artist.albums_dataset.first.pk.should == [@album.id1, @album.id2]
    
    @album.remove_all_tags
    @album.add_tag([@tag.id1, @tag.id2])
    @album.tags_dataset.first.pk.should == [@tag.id1, @tag.id2]
  end
  
  specify "should have remove method accept primary key and remove related album" do
    @artist.add_album(@album)
    @artist.reload.remove_album([@album.id1, @album.id2])
    @artist.reload.albums.should == []
    
    @album.add_tag(@tag)
    @album.reload.remove_tag([@tag.id1, @tag.id2])
    @tag.reload.albums.should == []
  end
  
  specify "should have remove method raise an error for one_to_many records if the object isn't already associated" do
    proc{@artist.remove_album([@album.id1, @album.id2])}.should raise_error(Sequel::Error)
    proc{@artist.remove_album(@album)}.should raise_error(Sequel::Error)
  end
end
