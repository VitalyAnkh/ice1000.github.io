git status

echo ""
echo "pulling..."

git pull origin master

git status

echo ""
read -p "Enter commit message:"

rm *~
rm **/*~
rm **/**/*~

git add *
git stage *
git commit -a -m "${REPLY}"

git status

echo ""
echo "commit finished"

git gc
git push https://ice1000@github.com/ice1000/ice1000.github.io.git master

echo "hia hia I have finished"
