import { useEffect, useState } from "react";
import Image from "next/image";
import { NextPage } from "next";
import toast from "react-hot-toast";
import { useAccount } from "wagmi";
import { MintAccs } from "~~/components/accessories/MintAccs";
import { TokenOption } from "~~/components/accessories/TokenOption";
import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";
import { ContractName } from "~~/utils/scaffold-eth/contract";

export type Accessory = {
  title: Exclude<ContractName, "SteveyWonder" | "Account" | "ERC6551Registry" | "Background">;
  imagePath: string;
};

const accessories: Accessory[] = [
  {
    title: "TShirt",
    imagePath: "tshirt.png",
  },
  {
    title: "Pants",
    imagePath: "pants.png",
  },
  {
    title: "Shoes",
    imagePath: "shoes.png",
  },
  {
    title: "Hairs",
    imagePath: "hairs.png",
  },
  {
    title: "Glasses",
    imagePath: "glasses.png",
  },
];

type AccTokenOption = {
  [key in Exclude<ContractName, "SteveyWonder" | "Account" | "ERC6551Registry" | "Background">]: number;
};

const Accessories: NextPage = () => {
  const { address } = useAccount();

  const { data: balanceOfStevey } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "balanceOf",
    args: [address],
  });

  const { data: tokenOfOwnerByIndex, error } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "tokenOfOwnerByIndex",
    args: [address, BigInt(0)],
    onSuccess: data => {
      accessories.forEach(({ title }) => {
        setAccTokenOption(prev => {
          return {
            ...prev,
            [title]: Number(data),
          };
        });
      });
    },
    onError: () => {
      accessories.forEach(({ title }) => {
        setAccTokenOption(prev => {
          return {
            ...prev,
            [title]: -1,
          };
        });
      });
    },
  });

  const AccTokenOptionState: AccTokenOption = accessories.reduce(
    (acc, { title }) => ({
      ...acc,
      [title]: error ? -1 : Number(tokenOfOwnerByIndex),
    }),
    {} as AccTokenOption,
  );

  const [accTokenOption, setAccTokenOption] = useState<AccTokenOption>(AccTokenOptionState);

  useEffect(() => {
    console.log(accTokenOption);
  }, [accTokenOption]);

  return (
    <div className="mx-[5rem] my-[4.5rem]">
      <h1 className="font-bold text-4xl pb-8">Accessories</h1>
      <div className="w-fit flex flex-row gap-10 flex-wrap">
        {accessories.map(({ title, imagePath }) => (
          <div key={title} className="py-4 px-2 rounded-xl bg-[#161829] border border-gray-100 border-opacity-5">
            <div className="flex justify-center">
              <Image src={`/images/accessories/${imagePath.toString()}`} alt={title} width={300} height={300} />
            </div>
            <div className="flex flex-col gap-1 mb-2">
              <div className="text-2xl font-medium mx-6 mt-4">{title}</div>
              <hr className="mx-5 h-0.5 border-gray-500 my-2 opacity-10" />
              <div className="flex flex-col gap-2 md:mx-5">
                <div className="flex justify-center md:justify-normal">
                  <span className="text-xl font-medium text-gray-300">For Stevey</span>
                </div>
                <div className="flex flex-col gap-2 md:flex-row md:justify-between items-center">
                  {balanceOfStevey !== undefined ? (
                    <select
                      className="select select-md select-bordered min-w-[50%] rounded-xl text-center p-0"
                      onChange={e =>
                        setAccTokenOption(prev => {
                          return {
                            ...prev,
                            [title]: Number(e.target.value),
                          };
                        })
                      }
                    >
                      {Number(balanceOfStevey) > 0 ? (
                        [...Array(Number(balanceOfStevey))].map((_, index) => {
                          return <TokenOption key={index} index={BigInt(index)} />;
                        })
                      ) : (
                        <option disabled selected>
                          0
                        </option>
                      )}
                    </select>
                  ) : (
                    <div className="loading loading-spinner text-secondary-content"></div>
                  )}
                  {accTokenOption[title] > 0 ? (
                    <MintAccs contractName={title} name="Mint" key={title} tokenId={accTokenOption[title]} />
                  ) : (
                    <button
                      className="flex items-center text-xl bg-secondary hover:bg-secondary-focus text-white font-medium py-2 px-4 rounded"
                      onClick={() => {
                        toast("You need to mint a Stevey first!", {
                          icon: "🦊",
                          style: {
                            borderRadius: "10px",
                            background: "#3C44FF",
                            color: "#fff",
                          },
                        });
                      }}
                    >
                      Mint
                    </button>
                  )}
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Accessories;
