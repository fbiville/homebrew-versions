class Liquigraph200 < Formula
  desc "Migration runner for Neo4j"
  homepage "http://www.liquigraph.org"
  url "https://github.com/fbiville/liquigraph/archive/liquigraph-2.0.0.tar.gz"
  sha256 "2c9232aa4db0d8724733643b6a919910899d8e9d49965bf48dbda044c9a00021"
  head "https://github.com/fbiville/liquigraph.git"

  depends_on "maven" => :build
  depends_on :java => "1.7+"

  def install
    ENV.java_cache
    system "mvn", "-q", "clean", "package", "-DskipTests"
    (buildpath/"binaries").mkpath
    system "tar", "xzf", "liquigraph-cli/target/liquigraph-cli-bin.tar.gz", "-C", "binaries"
    libexec.install "binaries/liquigraph-cli/liquigraph.sh" => "liquigraph"
    libexec.install "binaries/liquigraph-cli/liquigraph-cli.jar"
    bin.install_symlink libexec/"liquigraph"
  end

  test do
    failing_hostname = "verrryyyy_unlikely_host"
    changelog = (testpath/"changelog")
    changelog.write <<-EOS.undent
      <?xml version="1.0" encoding="UTF-8"?>
      <changelog>
          <changeset id="hello-world" author="you">
              <query>CREATE (n:Sentence {text:'Hello monde!'}) RETURN n</query>
          </changeset>
          <changeset id="hello-world-fixed" author="you">
              <query>MATCH (n:Sentence {text:'Hello monde!'}) SET n.text='Hello world!' RETURN n</query>
          </changeset>
      </changelog>
      EOS
    assert_match(/UnknownHostException: #{failing_hostname}/,
      shell_output("#{bin}/liquigraph -c #{changelog.realpath} -g jdbc:neo4j://#{failing_hostname}:7474/ 2>&1", 1))
  end
end
