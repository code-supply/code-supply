defmodule ProcessorTest do
  use ExUnit.Case

  import TlsLbOperator.Processor

  test "when synchronising, replaces cert references in the ingress" do
    assert [
             %{
               "binding" => "kubernetes",
               "type" => "Synchronization",
               "objects" => [
                 %{
                   "object" => %{
                     "kind" => "Secret",
                     "type" => "kubernetes.io/tls",
                     "metadata" => %{
                       "name" => "tls-foo",
                       "namespace" => "affable"
                     }
                   }
                 },
                 %{
                   "object" => %{
                     "kind" => "Secret",
                     "type" => "kubernetes.io/tls",
                     "metadata" => %{
                       "name" => "tls-foo",
                       "namespace" => "affable"
                     }
                   }
                 },
                 %{
                   "object" => %{
                     "kind" => "Secret",
                     "type" => "something/else",
                     "metadata" => %{
                       "name" => "not-tls",
                       "namespace" => "affable"
                     }
                   }
                 }
               ]
             }
           ]
           |> process() == {:ok, {:replace_certs, ["tls-foo"]}}
  end

  test "when doing something unrecognised, just passes back the context" do
    assert [
             %{
               "binding" => "kubernetes",
               "type" => "UnknownThingy"
             }
           ]
           |> process() ==
             {:ok,
              {:unrecognised_binding_context,
               [%{"binding" => "kubernetes", "type" => "UnknownThingy"}]}}
  end

  test "when told of a new cert secret, replaces certs in the load balancer" do
    assert [
             %{
               "binding" => "kubernetes",
               "type" => "Event",
               "watchEvent" => "Added",
               "object" => %{
                 "kind" => "Secret",
                 "type" => "kubernetes.io/tls",
                 "metadata" => %{
                   "name" => "some-tls",
                   "namespace" => "affable"
                 }
               },
               "snapshots" => %{
                 "affable secrets" => [
                   %{
                     "object" => %{
                       "type" => "kubernetes.io/tls",
                       "metadata" => %{
                         "name" => "existing-thing",
                         "namespace" => "affable"
                       }
                     }
                   },
                   %{
                     "object" => %{
                       "type" => "Opaque",
                       "metadata" => %{
                         "name" => "no-thanks",
                         "namespace" => "affable"
                       }
                     }
                   }
                 ]
               }
             }
           ]
           |> process() == {:ok, {:replace_certs, ["existing-thing", "some-tls"]}}
  end

  test "when told of a new non-cert secret, does nothing" do
    assert [
             %{
               "binding" => "kubernetes",
               "type" => "Event",
               "watchEvent" => "Added",
               "object" => %{
                 "kind" => "Secret",
                 "type" => "Opaque",
                 "metadata" => %{
                   "name" => "not-a-tls",
                   "namespace" => "affable"
                 }
               }
             }
           ]
           |> process() == {:ok, :nothing_to_do}
  end

  test "when told of a cert secret deletion, replaces certs in the load balancer" do
    assert [
             %{
               "binding" => "kubernetes",
               "type" => "Event",
               "watchEvent" => "Deleted",
               "object" => %{
                 "kind" => "Secret",
                 "type" => "kubernetes.io/tls",
                 "metadata" => %{
                   "name" => "some-tls",
                   "namespace" => "affable"
                 }
               },
               "snapshots" => %{
                 "affable secrets" => [
                   %{
                     "object" => %{
                       "type" => "kubernetes.io/tls",
                       "metadata" => %{
                         "name" => "existing-thing",
                         "namespace" => "affable"
                       }
                     }
                   },
                   %{
                     "object" => %{
                       "type" => "Opaque",
                       "metadata" => %{
                         "name" => "no-thanks",
                         "namespace" => "affable"
                       }
                     }
                   },
                   %{
                     "object" => %{
                       "type" => "kubernetes.io/tls",
                       "metadata" => %{
                         "name" => "some-tls",
                         "namespace" => "affable"
                       }
                     }
                   }
                 ]
               }
             }
           ]
           |> process() == {:ok, {:replace_certs, ["existing-thing"]}}
  end

  test "when told of a non-cert secret deletion, does nothing" do
    assert [
             %{
               "binding" => "kubernetes",
               "type" => "Event",
               "watchEvent" => "Deleted",
               "object" => %{
                 "kind" => "Secret",
                 "type" => "Opaque",
                 "metadata" => %{
                   "name" => "not-a-tls",
                   "namespace" => "affable"
                 }
               }
             }
           ]
           |> process() == {:ok, :nothing_to_do}
  end
end
